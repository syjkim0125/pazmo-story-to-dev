# QA environment

Production is never used for QA.

- Target: local | preview   <!-- where QA runs before the merge; default local -->
- Setup: <command run once before starting the app, such as installing dependencies, or "none">
- Start: <command, and how to tell it is ready>
- Stop: <command>
- Base URL: <http://localhost:PORT; the runner picks a free port when the app reads it from PORT or a flag>
- Preview: off   <!-- or: how to find the URL for a branch, and how to tell it serves a commit -->
- Database: in-memory | per-run container | shared   <!-- shared: scenarios that change data run one at a time -->
- Login: <how, which test account; never a real customer account>
- Test data: <how to get the state a scenario needs: cart, coupon, card, flag>
- External services: <sandbox, mock, or "needs a person">
- Needs a person: <steps an agent cannot do, such as 2FA or payment authentication>
- QA scripts: `qa/<slug>.sh`, run with `BASE_URL=<base URL> bash qa/<slug>.sh`
- Browser test runner: <command such as `BASE_URL=<base URL> npx playwright test qa/<slug>.spec.ts`, or "none">
- Quality checks: kit default   <!-- or the repository's own commands for the accessibility scan and the performance run -->

## Integration (dev)

- Auto-merge: off   <!-- the human sets "on"; an agent never turns it on -->
- Integration branch: <dev>
- Production branch: <main>
- Dev base URL: <URL>
- Dev runs the merged commit when: <how to check, e.g. GET /version returns the commit>
- Dev QA in CI: <`.github/workflows/qa-dev.yml`, with repository variables DEV_BASE_URL and DEV_VERSION_PATH, or "none">
- Dev login and test data: <same as local, or how it differs>
