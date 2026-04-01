abbr -a pdev 'pnpm dev'
abbr -a padd 'pnpm add'
abbr -a prem 'pnpm remove'

function mkcd
    mkdir -p $argv[1]; and cd $argv[1]
end
