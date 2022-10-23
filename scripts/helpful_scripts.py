from brownie import network, config, accounts
# from web3 import web3

FORKED_LOCAL_ENVORMENTS = ["mainnet-fork", " mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVRONMENTS = ["development", "ganache-local"]

DECIMALS = 0
STARTING_PRICE = 200000000000

def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVORMENTS
    ):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

# def deploy_mocks(): 
#     print(f"The active network is {network.show_active()}")
#     print("Deploying Mocks...")
#     if len(MockV3Aggregator) <= 0:
#         MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": get_account()})
#         print("Mocks deployed!")