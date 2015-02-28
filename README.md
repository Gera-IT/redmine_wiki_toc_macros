## Redmine wiki table of content macros

###

Usage:

`{{wiki_toc(sort=!title, depth=100)}}`
where `sort` argument allows you to choose which field to use for sorting, and `depth` - how deep should tree be displayed.

Allowed fields for sort:

`title, created_at, modified_at, by_author, by_parent, !title, !created_at, !modified_at, !by_author, !by_parent`

Sign `!` before field name means to reverse ordering vice verse.
