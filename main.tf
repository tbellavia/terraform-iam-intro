terraform {
    required_providers {
        scaleway = {
            source = "scaleway/scaleway"
        }
    }
    required_version = ">= 0.13"
}

# 1. Create two applications
#   - developer
#   - db-admin
# 2. Create two groups
#   - developers
#   - db-admins
# 3. Add the applications created at step 1 to their groups
# 4. Create two policies
#   4.a. `developers` policy : AccessFull, DbReadOnly
#   4.b. `db-admins` policy : AccessFull

resource "scaleway_account_project" "iam_intro" {
    name = "iam_intro"
}

resource "scaleway_iam_application" "developer" {
    name = "developer"
}

resource "scaleway_iam_application" "db_admin" {
    name = "db_admin"
}

resource "scaleway_iam_group" "developers" {
    name = "developers"
    application_ids = [scaleway_iam_application.developer.id]
}

resource "scaleway_iam_group" "db_admins" {
    name = "db_admins"
    application_ids = [scaleway_iam_application.db_admin.id]
}

resource "scaleway_iam_policy" "developers_policy" {
    name = "developers permissions"
    group_id = scaleway_iam_group.developers.id
    rule {
        # use data ?
        project_ids = [scaleway_account_project.iam_intro.id]
        permission_set_names = ["AllProductsFullAccess", "RelationalDatabasesReadOnly"]
    }
}

resource "scaleway_iam_policy" "db_admin_policy" {
    name = "db admin permissions"
    group_id = scaleway_iam_group.db_admins.id
    rule {
        project_ids = [scaleway_account_project.iam_intro.id]
        permission_set_names = ["AllProductsFullAccess"]
    }
}

resource "scaleway_iam_api_key" "developer" {
    application_id = scaleway_iam_application.developer.id
}

resource "scaleway_iam_api_key" "db_admin" {
    application_id = scaleway_iam_application.db_admin.id
}

output "developer_api_access_key" {
    value = scaleway_iam_api_key.developer.access_key
    sensitive = true
}

output "developer_api_secret_key" {
    value = scaleway_iam_api_key.developer.secret_key
    sensitive = true
}

output "db_admin_api_access_key" {
    value = scaleway_iam_api_key.db_admin.access_key
    sensitive = true
}

output "db_admin_api_secret_key" {
    value = scaleway_iam_api_key.db_admin.secret_key
    sensitive = true
}
