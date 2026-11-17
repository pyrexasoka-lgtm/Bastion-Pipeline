[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Variables are set in BeforeAll and BeforeEach and read in It blocks.')]
param()

BeforeAll {
    $script = Join-Path $PSScriptRoot '../../scripts/promote.ps1'
    $digest = 'sha256:' + ('a' * 64)
    $image = "ghcr.io/example/app@$digest"
    # Fake cosign: a script that only returns the exit code the test needs.
    $cosignOk = Join-Path $TestDrive 'cosign-ok.ps1'
    $cosignFail = Join-Path $TestDrive 'cosign-fail.ps1'
    Set-Content -LiteralPath $cosignOk -Value 'exit 0'
    Set-Content -LiteralPath $cosignFail -Value 'exit 1'
}

Describe 'promote.ps1' {
    BeforeEach {
        $root = Join-Path $TestDrive ([guid]::NewGuid())
        $overlay = Join-Path $root 'deploy/overlays/dev'
        New-Item -ItemType Directory -Path $overlay -Force | Out-Null
        $kustomization = Join-Path $overlay 'kustomization.yaml'
        $original = "images:`n  - name: app`n    newName: old/name`n    digest: sha256:$('0' * 64)`n"
        [System.IO.File]::WriteAllText($kustomization, $original)
    }

    It 'writes the verified digest and keeps the final newline' {
        & pwsh -NoProfile -File $script -Image $image -PublicKey key.pub -Cosign $cosignOk -RepoRoot $root *> $null
        $LASTEXITCODE | Should -Be 0
        $text = [System.IO.File]::ReadAllText($kustomization)
        $text | Should -Match ([regex]::Escape("digest: $digest"))
        $text | Should -Match 'newName: ghcr.io/example/app'
        $text.EndsWith("`n") | Should -BeTrue
    }

    It 'changes nothing when signature verification fails' {
        & pwsh -NoProfile -File $script -Image $image -PublicKey key.pub -Cosign $cosignFail -RepoRoot $root *> $null
        $LASTEXITCODE | Should -Not -Be 0
        [System.IO.File]::ReadAllText($kustomization) | Should -BeExactly $original
    }
}
