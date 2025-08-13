### All My Checklists (iOS)

Native SwiftUI iOS app for reusable, personal checklists. Templates you can run repeatedly (e.g., Morning Routine, Domestic Flight, Library Trip). Local-only; no login.

Features
- Onboarding with optional sample templates
- Template creation and editing with drag reordering
- Run checklists with progress and history
- Settings: haptics, seed data, wipe data, show onboarding

Tech
- SwiftUI + SwiftData (iOS 17+)
- No external deps

Getting Started
1. Open `AllMyChecklists.xcodeproj` in Xcode 15+
2. Select an iOS Simulator and Run
3. Or build via CLI: `xcodebuild -project AllMyChecklists.xcodeproj -scheme AllMyChecklists -destination 'platform=iOS Simulator,name=iPhone 16' build`

Structure
- `AllMyChecklists/` Swift sources
- `project.yml` XcodeGen spec (optional)
