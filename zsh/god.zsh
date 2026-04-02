# =============================================================================
# ASMA ZSH settings — god commands + shortcuts
# Source this file from ~/.zshrc:
#   source ~/ASMA/scripts/zsh/god.zsh
# =============================================================================

# ---------------------------------------------------------------------------
# pnpm shortcuts
# ---------------------------------------------------------------------------
alias pdev='pnpm dev'
alias padd='pnpm add'
alias prem='pnpm remove'

# ---------------------------------------------------------------------------
# misc shortcuts
# ---------------------------------------------------------------------------
function mkcd() { mkdir -p "$1" && cd "$1"; }

# ---------------------------------------------------------------------------
# god commands
# ---------------------------------------------------------------------------
# >>> god commands >>>
function god() {
  local subcommand=$1

  case $subcommand in
    push)
      git push "${@:2}"
      ;;
    pull)
      if [[ " ${*:2} " == *" --master "* ]]; then
        git pull origin master
      else
        asma git pull
      fi
      ;;
    commit)
      local branch
      branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
      local merge_msg_file
      merge_msg_file=$(git rev-parse --git-dir 2>/dev/null)/MERGE_MSG

      # Parse optional --from <task> flag
      local task=""
      local args=("${@:2}")
      local i=0
      while [[ $i -lt ${#args[@]} ]]; do
        if [[ "${args[$i]}" == "--from" ]]; then
          i=$((i+1))
          task="${args[$i]}"
          break
        fi
        i=$((i+1))
      done
      if [[ -n "$task" && $task != ASMA-* ]]; then
        task="ASMA-$task"
      fi

      if [[ -f "$merge_msg_file" ]]; then
        git commit --no-edit
      elif [[ "$branch" == "master" ]]; then
        if [[ -n "$task" ]]; then
          # --from provided: generate AI message, then prepend ASMA key
          if asma git commit --auto-provider ai --include-unstaged --include-untracked --allow-protected-push; then
            local cur_subject
            cur_subject=$(git log -1 --format=%s)
            if [[ $cur_subject != *ASMA-* ]]; then
              local cur_body
              cur_body=$(git log -1 --format=%b)
              # Insert after conventional commit prefix e.g. "feat(scope): "
              if [[ $cur_subject =~ ^[a-z]+\([^)]+\)?: |^[a-z]+:  ]]; then
                local amended="${cur_subject/: /: $task }"
                git commit --amend -m "$amended" -m "$cur_body"
              else
                git commit --amend -m "$task $cur_subject" -m "$cur_body"
              fi
            fi
          fi
        elif [[ " ${*:2} " == *" --release "* ]]; then
          asma git commit --auto-provider ai --include-unstaged --include-untracked --skip-jira-key --allow-protected-push --force-release
        else
          asma git commit --auto-provider ai --include-unstaged --include-untracked --skip-jira-key --allow-protected-push
        fi
      else
        if [[ " ${*:2} " == *" --release "* ]]; then
          asma git commit --auto-provider ai --include-unstaged --include-untracked --force-release
        else
          asma git commit --auto-provider ai --include-unstaged --include-untracked
        fi
      fi
      ;;
    pr)
      if [[ " ${*} " == *" --open "* ]]; then
        if gh pr view --web 2>/dev/null; then
          : # PR exists, already opened
        else
          gh pr create --fill && gh pr view --web
        fi
      elif [[ $# -lt 2 ]]; then
        echo "Error: flag is required. Usage: god pr --from <ASMA-number|number> | god pr --open" >&2
        return 1
      else
        # support both: god pr --from 123  and  god pr 123
        local task=""
        local args=("${@:2}")
        local i=0
        while [[ $i -lt ${#args[@]} ]]; do
          if [[ "${args[$i]}" == "--from" ]]; then
            i=$((i+1))
            task="${args[$i]}"
            break
          elif [[ "${args[$i]}" != --* ]]; then
            task="${args[$i]}"
            break
          fi
          i=$((i+1))
        done
        if [[ -z "$task" ]]; then
          echo "Error: Jira ticket is required. Usage: god pr --from <ASMA-number|number>" >&2
          return 1
        fi
        if [[ $task != ASMA-* ]]; then
          task="ASMA-$task"
        fi
        asma git branch create --from "$task" && asma git commit --auto-provider ai --include-untracked --include-unstaged --push --create-pr && gh pr view --web
      fi
      ;;
    branch)
      if [[ $# -lt 2 ]]; then
        echo "Error: flag is required. Usage: god branch --from <ASMA-number|number>" >&2
        return 1
      fi
      local task=""
      local args=("${@:2}")
      local i=0
      while [[ $i -lt ${#args[@]} ]]; do
        if [[ "${args[$i]}" == "--from" ]]; then
          i=$((i+1))
          task="${args[$i]}"
          break
        elif [[ "${args[$i]}" != --* ]]; then
          task="${args[$i]}"
          break
        fi
        i=$((i+1))
      done
      if [[ -z "$task" ]]; then
        echo "Error: Jira ticket is required. Usage: god branch --from <ASMA-number|number>" >&2
        return 1
      fi
      if [[ $task != ASMA-* ]]; then
        task="ASMA-$task"
      fi
      asma git branch create --from "$task"
      ;;
    start)
      cd ~/asma/asma-modules && code .
      ;;
    ''|help|-h|--help)
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
      ;;
    *)
      echo "Unknown subcommand: $subcommand" >&2
      echo 'Run: god help' >&2
      return 1
      ;;
  esac
}
# <<< god commands <<<
