#!/usr/bin/env python3
"""
Academia Forense — Canonical E2E Test Runner & Harness.

Derived strictly from ORIGINAL_REQUEST.md, PROJECT.md, and TEST_INFRA.md.
Executes test suites across Tiers 1-4 with support for:
- Filtering by Tier (--tier 1|2|3|4)
- Filtering by Feature (--feature 1..28)
- Comprehensive execution (--all)
- Machine-readable reporting (--junit <path>, --json <path>)
- Detailed ANSI summary table and exit code 0/1 semantics.
"""

import argparse
import io
import json
import os
import re
import sys
import time
import unittest
import xml.etree.ElementTree as ET
from typing import Any, Dict, List, Optional, Tuple

# Ensure project root (/home/antigravity) is on sys.path so 'tests' package resolves
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

# ANSI color codes
RESET = "\033[0m"
BOLD = "\033[1m"
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
CYAN = "\033[36m"
WHITE = "\033[37m"
BG_DARK = "\033[40m"


class ForensicTestRecord:
    def __init__(self, test: unittest.TestCase):
        self.test_id = test.id()
        self.module = test.__class__.__module__
        self.class_name = test.__class__.__name__
        self.method_name = test._testMethodName
        self.description = test.shortDescription() or ""
        self.status = "PENDING"
        self.duration_sec = 0.0
        self.error_message: Optional[str] = None
        self.traceback_text: Optional[str] = None
        self.start_time = 0.0


class ForensicTestResult(unittest.TestResult):
    def __init__(self, stream=None, descriptions=None, verbosity=1):
        super().__init__(stream=stream, descriptions=descriptions, verbosity=verbosity)
        self.verbosity = verbosity
        self.records: List[ForensicTestRecord] = []
        self._current_record: Optional[ForensicTestRecord] = None
        self.start_wall_time = time.time()
        self.end_wall_time = 0.0

    def startTest(self, test: unittest.TestCase):
        super().startTest(test)
        record = ForensicTestRecord(test)
        record.start_time = time.perf_counter()
        self._current_record = record
        self.records.append(record)
        if self.verbosity >= 2:
            sys.stdout.write(f"  {CYAN}RUN{RESET}  {record.class_name}.{record.method_name} ... ")
            sys.stdout.flush()

    def addSuccess(self, test: unittest.TestCase):
        super().addSuccess(test)
        if self._current_record:
            self._current_record.duration_sec = time.perf_counter() - self._current_record.start_time
            self._current_record.status = "PASS"
        if self.verbosity >= 2:
            print(f"{GREEN}PASS{RESET} ({self._current_record.duration_sec:.3f}s)")

    def addFailure(self, test: unittest.TestCase, err):
        super().addFailure(test, err)
        if self._current_record:
            self._current_record.duration_sec = time.perf_counter() - self._current_record.start_time
            self._current_record.status = "FAIL"
            self._current_record.error_message = str(err[1])
            self._current_record.traceback_text = self._exc_info_to_string(err, test)
        if self.verbosity >= 2:
            print(f"{RED}FAIL{RESET}")

    def addError(self, test: unittest.TestCase, err):
        super().addError(test, err)
        if self._current_record:
            self._current_record.duration_sec = time.perf_counter() - self._current_record.start_time
            self._current_record.status = "ERROR"
            self._current_record.error_message = str(err[1])
            self._current_record.traceback_text = self._exc_info_to_string(err, test)
        if self.verbosity >= 2:
            print(f"{RED}ERROR{RESET}")

    def addSkip(self, test: unittest.TestCase, reason: str):
        super().addSkip(test, reason)
        if self._current_record:
            self._current_record.duration_sec = time.perf_counter() - self._current_record.start_time
            self._current_record.status = "SKIP"
            self._current_record.error_message = reason
        if self.verbosity >= 2:
            print(f"{YELLOW}SKIP{RESET} ({reason})")

    def stopTestRun(self):
        super().stopTestRun()
        self.end_wall_time = time.time()


def filter_test_suite_by_feature(suite: unittest.TestSuite, feature_num: int) -> unittest.TestSuite:
    """Recursively filters a test suite to keep tests covering feature_num (e.g., F1, F28)."""
    filtered = unittest.TestSuite()
    pattern_f = re.compile(rf"(?:\b|_)(?:f|feature_?)0?{feature_num}(?:\b|_)", re.IGNORECASE)

    for item in suite:
        if isinstance(item, unittest.TestSuite):
            sub = filter_test_suite_by_feature(item, feature_num)
            if sub.countTestCases() > 0:
                filtered.addTest(sub)
        elif isinstance(item, unittest.TestCase):
            test_id = item.id()
            method_name = item._testMethodName
            doc = item.shortDescription() or ""
            class_name = item.__class__.__name__
            class_doc = item.__class__.__doc__ or ""
            # Check if method, test_id, class, or doc mentions feature
            if (
                pattern_f.search(method_name)
                or pattern_f.search(test_id)
                or pattern_f.search(class_name)
                or pattern_f.search(doc)
                or pattern_f.search(class_doc)
                or f"F{feature_num}" in doc
                or f"Feature {feature_num}" in doc
                or f"Feature {feature_num}:" in doc
                or f"F0{feature_num}" in doc
                or f"Feature 0{feature_num}" in doc
            ):
                filtered.addTest(item)
    return filtered


def generate_junit_xml(result: ForensicTestResult, target_path: str) -> None:
    """Generates standard JUnit XML report."""
    testsuites = ET.Element("testsuites")
    total_time = sum(r.duration_sec for r in result.records)

    testsuite = ET.SubElement(
        testsuites,
        "testsuite",
        name="AcademiaForenseE2E",
        tests=str(len(result.records)),
        failures=str(len(result.failures)),
        errors=str(len(result.errors)),
        skipped=str(len(result.skipped)),
        time=f"{total_time:.3f}",
    )

    for record in result.records:
        testcase = ET.SubElement(
            testsuite,
            "testcase",
            classname=f"{record.module}.{record.class_name}",
            name=record.method_name,
            time=f"{record.duration_sec:.3f}",
        )
        if record.status == "FAIL":
            fail = ET.SubElement(
                testcase,
                "failure",
                message=record.error_message or "AssertionError",
                type="AssertionError",
            )
            fail.text = record.traceback_text or ""
        elif record.status == "ERROR":
            err = ET.SubElement(
                testcase,
                "error",
                message=record.error_message or "UnexpectedError",
                type="Error",
            )
            err.text = record.traceback_text or ""
        elif record.status == "SKIP":
            skip = ET.SubElement(testcase, "skipped", message=record.error_message or "Skipped")

    os.makedirs(os.path.dirname(os.path.abspath(target_path)), exist_ok=True)
    tree = ET.ElementTree(testsuites)
    tree.write(target_path, encoding="utf-8", xml_declaration=True)


def generate_json_report(result: ForensicTestResult, target_path: str) -> None:
    """Generates structured JSON execution report."""
    report = {
        "suite": "Academia Forense E2E Test Suite",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(result.start_wall_time)),
        "duration_sec": round(sum(r.duration_sec for r in result.records), 3),
        "summary": {
            "total": len(result.records),
            "passed": len([r for r in result.records if r.status == "PASS"]),
            "failed": len(result.failures),
            "errored": len(result.errors),
            "skipped": len(result.skipped),
        },
        "tests": [
            {
                "test_id": r.test_id,
                "module": r.module,
                "class": r.class_name,
                "method": r.method_name,
                "description": r.description,
                "status": r.status,
                "duration_sec": round(r.duration_sec, 4),
                "error": r.error_message,
            }
            for r in result.records
        ],
    }
    os.makedirs(os.path.dirname(os.path.abspath(target_path)), exist_ok=True)
    with open(target_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)


def print_summary_table(result: ForensicTestResult, title: str = "Test Execution Summary") -> None:
    """Prints a formatted ANSI table with test counts, metrics and statuses."""
    total = len(result.records)
    passed = len([r for r in result.records if r.status == "PASS"])
    failed = len(result.failures)
    errored = len(result.errors)
    skipped = len(result.skipped)
    total_duration = sum(r.duration_sec for r in result.records)

    print("\n" + "=" * 78)
    print(f"{BOLD}{CYAN} ACADEMIA FORENSE — E2E TEST RUNNER REPORT{RESET}")
    print("=" * 78)
    print(f" Scope: {title}")
    print(f" Timestamp: {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())}")
    print("-" * 78)

    # ANSI Table
    col_w = [14, 10, 10, 10, 10, 12]
    header = (
        f"{'TOTAL':<{col_w[0]}}"
        f"{'PASSED':<{col_w[1]}}"
        f"{'FAILED':<{col_w[2]}}"
        f"{'ERRORED':<{col_w[3]}}"
        f"{'SKIPPED':<{col_w[4]}}"
        f"{'DURATION':<{col_w[5]}}"
    )
    print(f"{BOLD}{header}{RESET}")
    print("-" * 78)

    pass_color = GREEN if passed == total and total > 0 else WHITE
    fail_color = RED if failed > 0 else WHITE
    err_color = RED if errored > 0 else WHITE

    row = (
        f"{total:<{col_w[0]}}"
        f"{pass_color}{passed:<{col_w[1]}}{RESET}"
        f"{fail_color}{failed:<{col_w[2]}}{RESET}"
        f"{err_color}{errored:<{col_w[3]}}{RESET}"
        f"{skipped:<{col_w[4]}}"
        f"{total_duration:.3f}s"
    )
    print(row)
    print("=" * 78)

    # Print failures / errors details if any
    if failed > 0 or errored > 0:
        print(f"\n{BOLD}{RED}FAILED / ERRORED TESTS DETAIL:{RESET}")
        for r in result.records:
            if r.status in ("FAIL", "ERROR"):
                print(f"\n[{r.status}] {r.test_id}")
                if r.error_message:
                    print(f"  Message: {r.error_message}")
                if r.traceback_text:
                    for line in r.traceback_text.splitlines()[-6:]:
                        print(f"    {line}")
        print("=" * 78)

    # Final verdict
    if failed == 0 and errored == 0 and total > 0:
        print(f"{BOLD}{GREEN}✓ ALL {total} TESTS PASSED (100% SUCCESS){RESET}\n")
    elif total == 0:
        print(f"{BOLD}{YELLOW}⚠ NO TESTS WERE DISCOVERED OR EXECUTED{RESET}\n")
    else:
        print(f"{BOLD}{RED}✗ TEST RUN FAILED ({failed} failures, {errored} errors){RESET}\n")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Academia Forense E2E Test Harness & Suite Runner",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--all", action="store_true", help="Run all tests across Tiers 1-5")
    parser.add_argument("--tier", choices=["1", "2", "3", "4", "5"], help="Execute specific test tier")
    parser.add_argument("--feature", type=int, choices=range(1, 29), help="Filter tests by feature (1..28)")
    parser.add_argument("--junit", type=str, help="Output path for JUnit XML report")
    parser.add_argument("--json", type=str, help="Output path for JSON report")
    parser.add_argument("-v", "--verbose", action="count", default=1, help="Verbosity level")

    args = parser.parse_args()

    tests_root = os.path.dirname(os.path.abspath(__file__))
    e2e_root = os.path.join(tests_root, "e2e")

    # Determine target directories
    discovery_dirs = []
    scope_title = ""

    if args.tier:
        tier_mapping = {
            "1": "tier1_features",
            "2": "tier2_boundaries",
            "3": "tier3_pairwise",
            "4": "tier4_scenarios",
            "5": "tier5_adversarial",
        }
        target_sub = tier_mapping[args.tier]
        target_dir = os.path.join(e2e_root, target_sub)
        discovery_dirs.append(target_dir)
        scope_title = f"Tier {args.tier} ({target_sub})"
    elif args.all or (not args.tier and not args.feature):
        # Default or --all: search entire e2e tree
        discovery_dirs.append(e2e_root)
        scope_title = "All E2E Tiers (Tiers 1-5)"
    else:
        discovery_dirs.append(e2e_root)
        scope_title = "Filtered Test Run"

    if args.feature:
        scope_title += f" [Feature F{args.feature}]"

    loader = unittest.defaultTestLoader
    master_suite = unittest.TestSuite()

    for d in discovery_dirs:
        if os.path.exists(d):
            suite = loader.discover(start_dir=d, pattern="test_*.py", top_level_dir=project_root)
            master_suite.addTest(suite)

    if args.feature:
        master_suite = filter_test_suite_by_feature(master_suite, args.feature)

    test_count = master_suite.countTestCases()
    print(f"\n{BOLD}{CYAN}▶ Starting Academia Forense E2E Test Runner...{RESET}")
    print(f"  Scope: {scope_title}")
    print(f"  Discovered Tests: {test_count}")
    print("-" * 78)

    result = ForensicTestResult(verbosity=args.verbose)
    master_suite.run(result)
    result.stopTestRun()

    # Print summary
    print_summary_table(result, title=scope_title)

    # Emit reports if requested
    if args.junit:
        generate_junit_xml(result, args.junit)
        print(f"  JUnit XML report generated: {args.junit}")

    if args.json:
        generate_json_report(result, args.json)
        print(f"  JSON summary report generated: {args.json}")

    # Return exit code: 0 on 100% pass, 1 on any failure/error or 0 tests
    if len(result.failures) == 0 and len(result.errors) == 0 and test_count > 0:
        return 0
    elif test_count == 0:
        return 1
    else:
        return 1


if __name__ == "__main__":
    sys.exit(main())
