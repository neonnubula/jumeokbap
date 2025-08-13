import XCTest

final class OnboardingAndRunUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func test_onboarding_then_run_sample() {
        let app = XCUIApplication()
        app.launchArguments = ["-resetOnboarding", "-wipeData", "-seedSamples"]
        app.launch()

        // Progress through onboarding
        let continueButton = app.buttons["Continue"]
        if continueButton.waitForExistence(timeout: 3) {
            continueButton.tap(); continueButton.tap(); continueButton.tap()
        }
        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: 3))
        getStarted.tap()

        // Home appears and has sections; tap first cell
        let firstCell = app.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 3))
        firstCell.tap()

        // Tap Run
        var tappedRun = false
        let startRun = app.descendants(matching: .any).matching(identifier: "StartRunButton").firstMatch
        if startRun.waitForExistence(timeout: 6) {
            startRun.tap(); tappedRun = true
        } else {
            let navRun = app.navigationBars.buttons["Run"]
            if navRun.waitForExistence(timeout: 4) {
                navRun.tap(); tappedRun = true
            } else {
                let runButton = app.buttons.matching(identifier: "RunTemplateButton").firstMatch
                if runButton.waitForExistence(timeout: 4) {
                    runButton.tap(); tappedRun = true
                }
            }
        }
        XCTAssertTrue(tappedRun)

        // In run view, ensure progress is visible
        let finish = app.buttons["Finish"]
        XCTAssertTrue(finish.waitForExistence(timeout: 3))
    }
}

