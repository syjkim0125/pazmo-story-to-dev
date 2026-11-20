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

## Integration (dev)

- Auto-merge: off   <!-- the human sets "on"; an agent never turns it on -->
- Integration branch: <dev>
- Production branch: <main>
- Dev base URL: <URL>
- Dev runs the merged commit when: <how to check, e.g. GET /version returns the commit>
- Dev login and test data: <same as local, or how it differs>
