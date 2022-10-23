from brownie import FundMe, network, config
from scripts.helpful_scripts import (
    get_account,
    # deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVRONMENTS
)

def deploy_contract():
    account = get_account()
    fund_me = FundMe.deploy({"from": account}, publish_source=True)
    print(f"Contract deployed to {fund_me.address}")


def main():
    deploy_contract()