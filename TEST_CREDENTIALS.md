# TaskFlow — Test Credentials

The assignment requires four reviewer accounts from the provided `auth_mock` data.

| Organization | Role | Email | Password |
|---|---|---|---|
| Organization A | Admin | `<copy from auth_mock>` | `<copy from auth_mock>` |
| Organization A | Member | `<copy from auth_mock>` | `<copy from auth_mock>` |
| Organization B | Admin | `<copy from auth_mock>` | `<copy from auth_mock>` |
| Organization B | Member | `<copy from auth_mock>` | `<copy from auth_mock>` |

## Reviewer Checks

### Org A Admin
Verify Org A data and admin-only project/member permissions.

### Org A Member
Verify Org A data is visible but admin-only actions are blocked.

### Org B Admin
Verify Org B data isolation and admin permissions.

### Org B Member
Verify Org B data isolation and member restrictions.

**Important:** Replace the placeholders only with the credentials from the provided `TaskFlow-MockData.json` `auth_mock` section. Do not invent credentials or expose access/refresh tokens unnecessarily.
