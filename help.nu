#!/usr/bin/env nu

let iroha_git = 'https://github.com/hyperledger/iroha.git'
let iroha_rev = '3671fdb0a01adcea5742557079692ce5d526c430'
let explorer_git = 'https://github.com/soramitsu/iroha2-block-explorer-backend.git'

def main [...args] {
    let command = $args.0
    if $command == "install" {
        let what = $args.1
        if $what == "explorer" {
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
            cp explorer-git/target/release/iroha2_explorer_web ./explorer/

            echo "explorer is built. also installing bunyan"
            cargo install bunyan --root ./tmp
        } else {
            echo "I dont know what do you mean"
        }
    } else if $command == "config" {
        cp configs/iroha_config.json iroha/config.json
        cp configs/iroha_genesis.json iroha/genesis.json
        cp configs/client_config.json explorer/client_config.json
        echo "configs are copied"
    } else if $command == "run" {
        let what = $args.1
        if $what == "iroha" {
            cd iroha
            docker-compose up
        } else if $what == "explorer" {
            cd explorer
            ./iroha2_explorer_web --dev-actor
        } else if $what == "both" {
            [iroha explorer] | par-each { |it|
                nu ./help.nu run $it
            }
        }
    } else if $command == 'clean' {
        echo 'cleaning iroha'
        rm -r ./iroha/*
    } else if $command == "help" {
        echo "
        Hi!
        I am here to help you with explorer & iroha deployment

        Firstly, install explorer:

            # clone git repo
            git clone <explorer-repo> explorer-git

            # and build it
            <script> install explorer

        Then, setup configs:

            <script> config

        Now everything is ready to be run. You can run both in parallel:
        
            <script> run both

        Or separately:

            <script> run iroha
            <script> run explorer

        Check out http://localhost:4000 !
        "
    }

    # add cleaning of blocks/configs?
}
