# QA environment

Production is never used for QA.

- Environment: <local | staging>
- Start: <command, and how to tell it is ready>
- Stop: <command>
- Base URL: <http://localhost:PORT or the staging URL>
- Login: <how, which test account; never a real customer account>
- Test data: <how to get the state a scenario needs: cart, coupon, card, flag>
- External services: <sandbox, mock, or "needs a person">
- Needs a person: <steps an agent cannot do, such as 2FA or payment authentication>
- QA scripts: `qa/<slug>.sh`, run with `BASE_URL=<base URL> bash qa/<slug>.sh`
- Browser test runner: <command such as `BASE_URL=<base URL> npx playwright test qa/<slug>.spec.ts`, or "none">

## Integration (dev)

- Auto-merge: off   <!-- the human sets "on"; an agent never turns it on -->
- Integration branch: <dev>
- Production branch: <main>
- Dev base URL: <URL>
- Dev runs the merged commit when: <how to check, e.g. GET /version returns the commit>
- Dev QA in CI: <`.github/workflows/qa-dev.yml`, with repository variables DEV_BASE_URL and DEV_VERSION_PATH, or "none">
- Dev login and test data: <same as local, or how it differs>
