const String testMockDataJson = '''
{
	"organizations": [
		{
			"id": "org_a1b2c3",
			"name": "Nimbus Digital",
			"created_at": "2025-11-02T09:15:00Z"
		},
		{
			"id": "org_d4e5f6",
			"name": "Harborlight Studios",
			"created_at": "2025-12-18T14:40:00Z"
		}
	],
	"users": [
		{
			"id": "user_001",
			"name": "Ava Thompson",
			"email": "ava.admin@nimbusdigital.test",
			"avatar_url": "https://i.pravatar.cc/150?img=1"
		},
		{
			"id": "user_002",
			"name": "Marcus Lee",
			"email": "marcus.member@nimbusdigital.test",
			"avatar_url": "https://i.pravatar.cc/150?img=2"
		},
		{
			"id": "user_003",
			"name": "Priya Nair",
			"email": "priya.member@nimbusdigital.test",
			"avatar_url": "https://i.pravatar.cc/150?img=3"
		},
		{
			"id": "user_004",
			"name": "Daniel Osei",
			"email": "daniel.admin@harborlightstudios.test",
			"avatar_url": "https://i.pravatar.cc/150?img=4"
		},
		{
			"id": "user_005",
			"name": "Elena Vargas",
			"email": "elena.member@harborlightstudios.test",
			"avatar_url": "https://i.pravatar.cc/150?img=5"
		}
	],
	"org_members": [
		{ "org_id": "org_a1b2c3", "user_id": "user_001", "role": "org_admin" },
		{ "org_id": "org_a1b2c3", "user_id": "user_002", "role": "member" },
		{ "org_id": "org_a1b2c3", "user_id": "user_003", "role": "member" },
		{ "org_id": "org_d4e5f6", "user_id": "user_004", "role": "org_admin" },
		{ "org_id": "org_d4e5f6", "user_id": "user_005", "role": "member" }
	],
	"projects": [
		{
			"id": "proj_1001",
			"org_id": "org_a1b2c3",
			"name": "Website Relaunch",
			"description": "Redesign and rebuild the marketing website.",
			"task_count": 2,
			"status": "active",
			"created_at": "2025-12-01T10:00:00Z"
		},
		{
			"id": "proj_1003",
			"org_id": "org_d4e5f6",
			"name": "Client Onboarding Revamp",
			"description": "Streamline the onboarding flow.",
			"task_count": 1,
			"status": "active",
			"created_at": "2026-02-05T10:00:00Z"
		}
	],
	"tasks": [
		{
			"id": "task_2001",
			"project_id": "proj_1001",
			"title": "Set up design tokens in Figma",
			"description": "Define color, spacing, and typography tokens.",
			"status": "done",
			"priority": "medium",
			"assignee_id": "user_002",
			"due_date": "2026-01-05",
			"created_at": "2025-12-02T09:00:00Z"
		},
		{
			"id": "task_2002",
			"project_id": "proj_1001",
			"title": "Build responsive nav component",
			"description": "Implement the header navigation with mobile drawer.",
			"status": "in_progress",
			"priority": "high",
			"assignee_id": "user_003",
			"due_date": "2026-01-20",
			"created_at": "2025-12-05T09:00:00Z"
		},
		{
			"id": "task_2012",
			"project_id": "proj_1003",
			"title": "Draft onboarding checklist",
			"description": "New-client checklist covering first 30 days.",
			"status": "todo",
			"priority": "low",
			"assignee_id": "user_005",
			"due_date": "2026-02-12",
			"created_at": "2026-02-06T09:00:00Z"
		}
	],
	"comments": [
		{
			"id": "cmt_3001",
			"task_id": "task_2002",
			"author_id": "user_001",
			"body": "Let's use the drawer pattern.",
			"created_at": "2025-12-20T11:00:00Z"
		}
	],
	"notifications": [
		{
			"id": "notif_4001",
			"user_id": "user_002",
			"type": "task_assigned",
			"task_id": "task_2001",
			"message": "You were assigned to task",
			"read": false,
			"created_at": "2025-12-10T09:05:00Z"
		}
	],
	"auth_mock": {
		"test_credentials": [
			{
				"email": "ava.admin@nimbusdigital.test",
				"password": "Password123!",
				"org_id": "org_a1b2c3",
				"role": "org_admin"
			},
			{
				"email": "marcus.member@nimbusdigital.test",
				"password": "Password123!",
				"org_id": "org_a1b2c3",
				"role": "member"
			},
			{
				"email": "daniel.admin@harborlightstudios.test",
				"password": "Password123!",
				"org_id": "org_d4e5f6",
				"role": "org_admin"
			},
			{
				"email": "elena.member@harborlightstudios.test",
				"password": "Password123!",
				"org_id": "org_d4e5f6",
				"role": "member"
			}
		],
		"mock_login_response": {
			"access_token": "mock.access.token.short_lived",
			"refresh_token": "mock.refresh.token.long_lived",
			"access_token_expires_in_seconds": 900,
			"refresh_token_expires_in_seconds": 604800
		}
	}
}
''';
