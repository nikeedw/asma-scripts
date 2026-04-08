# fish completions for god helper command

# Returns completions from asma's own completion engine
function __god_complete_asma_ticket
    set -l token (commandline -ct)
    complete -C "asma git branch create --from $token"
end

# True when the token immediately before the cursor is --from
function __god_prev_token_is_from
    set -l tokens (commandline -opc)
    test "$tokens[-1]" = --from
end

complete -c god -f

complete -c god -n "__fish_use_subcommand" -a push     -d "Run git push"
complete -c god -n "__fish_use_subcommand" -a pull     -d "Run git pull"

# pull flags
complete -c god -n "__fish_seen_subcommand_from pull" -a --master -d "Pull from origin master"
complete -c god -n "__fish_seen_subcommand_from pull" -a --recursive -d "Run asma git pull"
complete -c god -n "__fish_use_subcommand" -a commit   -d "Run AI-assisted asma git commit"

# commit flags
complete -c god -n "__fish_seen_subcommand_from commit; and not __god_prev_token_is_from" -a --release -d "Force release (master only)"
complete -c god -n "__fish_seen_subcommand_from commit; and not __god_prev_token_is_from" -a --from   -d "Jira ticket to prepend to commit message (master only)"
complete -c god -n "__fish_seen_subcommand_from commit; and __god_prev_token_is_from"            -a "(__god_complete_asma_ticket)"
complete -c god -n "__fish_use_subcommand" -a pr       -d "Create branch from ticket, commit and open PR"
complete -c god -n "__fish_use_subcommand" -a branch   -d "Create branch from ticket"
complete -c god -n "__fish_use_subcommand" -a start    -d "Open asma-modules in VS Code"
complete -c god -n "__fish_use_subcommand" -a help     -d "Show usage"

# pr: show --from and --open as plain completions (visible without typing --)
complete -c god -n "__fish_seen_subcommand_from pr; and not __god_prev_token_is_from" -a --from -d "Jira ticket to create branch and PR from"
complete -c god -n "__fish_seen_subcommand_from pr; and not __god_prev_token_is_from" -a --open -d "Open existing PR for current branch in browser"

# pr: show Jira tickets only right after --from
complete -c god -n "__fish_seen_subcommand_from pr; and __god_prev_token_is_from" -a "(__god_complete_asma_ticket)"

# branch: same pattern
complete -c god -n "__fish_seen_subcommand_from branch; and not __god_prev_token_is_from" -a --from -d "Jira ticket to create branch from"
complete -c god -n "__fish_seen_subcommand_from branch; and __god_prev_token_is_from" -a "(__god_complete_asma_ticket)"
