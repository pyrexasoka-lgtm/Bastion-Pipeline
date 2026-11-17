from __future__ import annotations

from pathlib import Path
from typing import Any

import pytest

from scripts.release import sonar_status

SHA = "a" * 40


def _fetcher(analyses: list[dict[str, Any]], gate: dict[str, Any] | None = None) -> Any:
    def fetch(url: str) -> dict[str, Any]:
        if "/project_analyses/search" in url:
            return {"analyses": analyses}
        assert "analysisId=AN1" in url
        return {"projectStatus": gate or {}}

    return fetch


def test_pass_when_gate_ok_for_the_released_commit() -> None:
    fetch = _fetcher([{"key": "AN1", "revision": SHA}], {"status": "OK", "conditions": []})
    assert sonar_status.status_for("proj", SHA, fetch) == "PASS"


def test_fail_lists_failed_conditions() -> None:
    gate = {
        "status": "ERROR",
        "conditions": [
            {"status": "ERROR", "metricKey": "new_coverage"},
            {"status": "OK", "metricKey": "new_bugs"},
        ],
    }
    fetch = _fetcher([{"key": "AN1", "revision": SHA}], gate)
    assert sonar_status.status_for("proj", SHA, fetch) == "FAIL: new_coverage"


def test_no_analysis_for_the_commit_is_none() -> None:
    fetch = _fetcher([{"key": "OTHER", "revision": "b" * 40}])
    assert sonar_status.status_for("proj", SHA, fetch) is None


def test_project_key_read_from_properties(tmp_path: Path) -> None:
    props = tmp_path / "sonar-project.properties"
    props.write_text("# c\nsonar.organization=o\nsonar.projectKey=o_p\n")
    assert sonar_status.project_key(props) == "o_p"


def test_main_writes_nothing_when_unreachable(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    def boom(url: str) -> dict[str, Any]:
        raise OSError("network down")

    monkeypatch.setattr(sonar_status, "https_json", boom)
    out = tmp_path / "sonarcloud.txt"
    assert sonar_status.main(["--revision", SHA, "--out", str(out)]) == 0
    assert not out.exists()


def test_main_writes_nothing_on_an_unexpected_reply(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(sonar_status, "https_json", lambda url: ["not", "an", "object"])
    out = tmp_path / "sonarcloud.txt"
    assert sonar_status.main(["--revision", SHA, "--out", str(out)]) == 0
    assert not out.exists()
