#!/usr/bin/env nu

let iroha_git = 'https://github.com/hyperledger/iroha.git'
let iroha_rev = '3671fdb0a01adcea5742557079692ce5d526c430'
let explorer_git = 'https://github.com/soramitsu/iroha2-block-explorer-backend.git'

def main [...args] {
    let command = $args.0
    if $command == "install" {
        let what = $args.1
        if $what == "iroha" {
            echo "installing iroha..."
            cargo install --git $iroha_git --rev $iroha_rev --root ./tmp iroha
            mkdir iroha
            cp ./tmp/bin/iroha ./iroha/
            echo "done"
        } else if $what == "explorer" {
            
            # check if it is cloned
            if 'explorer-git' not-in (ls).name {
                echo "you should clone git repo first"
                echo "clone it into explorer-git dir, please"
                exit 1
                }
                
            echo "building explorer..."
            cd explorer-git
            cargo build --release --features dev_actor
            cd ../

            mkdir explorer
            cp explorer-git/target/release/iroha2_web_explorer ./explorer/

            echo "explorer is built. also installing bunyan"
            cargo install bunyan --root ./tmp
        }
    } else if $command == "config" {
        cp configs/iroha_config.json iroha/config.json
        cp configs/iroha_genesis.json iroha/genesis.json
        cp configs/client_config.json explorer/client_config.json
    } else if $command == "run" {
        let what = $args.1
        if $what == "iroha" {
            cd iroha
            ./iroha --submit-ge/target
            nesis
        } else if $what == "explorer" {
            cd explorer
            ./iroha2_explorer_web --dev-actor | ../tmp/bin/bunyan
        }
    } else if $command == "help" {
        echo "
        Hi!
        I am here to help you with explorer & iroha deployment

        Firstly, install iroha:

            <script> install iroha
        
        Then, install explorer:

            # clone git repo
            git clone <explorer-repo> explorer-git

            # and build it
            <script> install explorer

        Then, setup configs:

            <script> config

        Now everything is ready to be run. Firstly start Iroha:
        
            <script> run iroha

        And in parallel start explorer:

            <script> run explorer

        Checkout http://localhost:4000 !
        "
    }

    # add cleaning of blocks/configs?
}
