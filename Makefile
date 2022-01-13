-include .env

# dapp deps
update:; dapp update

all    :; dapp build
clean  :; dapp clean
test   :; dapp test
deploy :; dapp create DapptoolsDemo
