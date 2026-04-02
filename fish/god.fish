function god --description 'Local shortcut commands for God'
    set -l subcommand $argv[1]

    switch $subcommand
        case push
            git push $argv[2..-1]
        case pull
            if contains -- --master $argv[2..-1]
                git pull origin master
            else
                asma git pull
            end
        case commit
            set -l branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
            set -l merge_msg_file (git rev-parse --git-dir 2>/dev/null)/MERGE_MSG

            # Parse optional --from <task> flag
            set -l task ""
            set -l i 2
            while test $i -le (count $argv)
                if test "$argv[$i]" = --from
                    set i (math $i + 1)
                    if test $i -le (count $argv)
                        set task $argv[$i]
                    end
                    break
                end
                set i (math $i + 1)
            end
            if test -n "$task"; and not string match -q 'ASMA-*' "$task"
                set task "ASMA-$task"
            end

            if test -f "$merge_msg_file"
                git commit --no-edit
            else if test "$branch" = master
                if test -n "$task"
                    # --from provided: generate AI message, then prepend ASMA key
                    if asma git commit --auto-provider ai --include-unstaged --include-untracked --allow-protected-push
                        set -l cur_subject (git log -1 --format=%s)
                        if not string match -q '*ASMA-*' "$cur_subject"
                            set -l cur_body (git log -1 --format=%b)
                            # Insert after conventional commit prefix e.g. "feat(scope): "
                            if string match -qr '^[a-z]+\([^)]+\)?: |^[a-z]+: ' "$cur_subject"
                                set -l amended (string replace -r ': ' ": $task " "$cur_subject")
                                git commit --amend -m "$amended" -m "$cur_body"
                            else
                                git commit --amend -m "$task $cur_subject" -m "$cur_body"
                            end
                        end
                    end
                else if contains -- --release $argv[2..-1]
                    asma git commit --auto-provider ai --include-unstaged --include-untracked --skip-jira-key --allow-protected-push --force-release
                else
                    asma git commit --auto-provider ai --include-unstaged --include-untracked --skip-jira-key --allow-protected-push
                end
            else
                if contains -- --release $argv[2..-1]
                    asma git commit --auto-provider ai --include-unstaged --include-untracked --force-release
                else
                    asma git commit --auto-provider ai --include-unstaged --include-untracked
                end
            end
        case pr
            if contains -- --open $argv[2..-1]
                if gh pr view --web 2>/dev/null
                    # PR exists, already opened in browser
                else
                    # No PR yet — create it (auto title from branch), then open it
                    gh pr create --fill; and gh pr view --web
                end
            else if test (count $argv) -lt 2
                echo "Error: flag is required. Usage: god pr --from <ASMA-number|number> | god pr --open" >&2
                return 1
            else
                # support both: god pr --from 123  and  god pr 123
                set -l task ""
                set -l i 2
                while test $i -le (count $argv)
                    if test "$argv[$i]" = --from
                        set i (math $i + 1)
                        set task $argv[$i]
                        break
                    else if not string match -q '--*' $argv[$i]
                        set task $argv[$i]
                        break
                    end
                    set i (math $i + 1)
                end
                if test -z "$task"
                    echo "Error: Jira ticket is required. Usage: god pr --from <ASMA-number|number>" >&2
                    return 1
                end
                if not string match -q 'ASMA-*' $task
                    set task "ASMA-$task"
                end
                asma git branch create --from $task; and asma git commit --auto-provider ai --include-untracked --include-unstaged --push --create-pr; and gh pr view --web
            end
        case branch
            if test (count $argv) -lt 2
                echo "Error: flag is required. Usage: god branch --from <ASMA-number|number>" >&2
                return 1
            end
            set -l task ""
            set -l i 2
            while test $i -le (count $argv)
                if test "$argv[$i]" = --from
                    set i (math $i + 1)
                    set task $argv[$i]
                    break
                else if not string match -q '--*' $argv[$i]
                    set task $argv[$i]
                    break
                end
                set i (math $i + 1)
            end
            if test -z "$task"
                echo "Error: Jira ticket is required. Usage: god branch --from <ASMA-number|number>" >&2
                return 1
            end
            if not string match -q 'ASMA-*' $task
                set task "ASMA-$task"
            end
            asma git branch create --from $task
        case start
            cd ~/asma/asma-modules; and code .
        case '' help -h --help
            echo 'Usage: god push [extra args]'
            echo '       god pull [--master]'
            echo '       god commit [--release]'
            echo '       god pr --from <ASMA-number|number>'
            echo '       god pr --open'
            echo '       god branch --from <ASMA-number|number>'
            echo '       god start'
            echo ''
            echo 'god push               -> git push'
            echo 'god pull               -> asma git pull'
            echo 'god pull --master      -> git pull origin master'
            echo 'god commit             -> asma git commit --auto-provider ai --include-unstaged --include-untracked'
            echo 'god commit (master)    -> + --skip-jira-key --allow-protected-push'
            echo 'god commit --from 123  -> AI message on master, then amend to prepend ASMA-123 (no --skip-jira-key)'
            echo 'god commit --release   -> + --force-release  (master only)'
            echo 'god commit (MERGING)   -> git commit --no-edit'
            echo 'god pr --from 123      -> asma git branch create --from ASMA-123; asma git commit ... --push --create-pr; gh pr view --web'
            echo 'god pr --open          -> gh pr view --web (or gh pr create --fill if no PR yet)'
            echo 'god branch --from 123  -> asma git branch create --from ASMA-123'
            echo 'god start              -> cd ~/asma/asma-modules && code .'
        case '*'
            echo "Unknown subcommand: $subcommand" >&2
            echo 'Run: god help' >&2
            return 1
    end
end
