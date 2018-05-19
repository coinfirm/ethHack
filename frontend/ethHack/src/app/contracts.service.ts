import { Injectable } from '@angular/core';
import * as Web3 from 'web3';

declare let require: any;
declare let window: any;

const tokenAbi = require('../../../../build/contracts/Func.json').abi;

@Injectable({
  providedIn: 'root'
})
export class ContractsService {
  private _account: string = null;
  private _accounts: Array<string> = null;
  private _web3: any;

  private _tokenContract: any;
  private _tokenContractAddress = '0x7414ecd03a29480533dd02b17be5f3a44cc27ed3'; // address from migrate trx

  constructor() {
    if (typeof window.web3 !== 'undefined') {
      // Use Mist/MetaMask's provider
      this._web3 = new Web3(window.web3.currentProvider);
    } else {
        alert('Please use a dapp browser like mist or MetaMask plugin for chrome');
    }
    this._tokenContract = this._web3.eth.contract(tokenAbi).at(this._tokenContractAddress);
   }

   public async getAccounts(): Promise<Array<string>> {
    if (this._accounts == null) {
      this._accounts = await new Promise((resolve, reject) => {
        this._web3.eth.getAccounts((err, accs) => {
          if (err != null) {
            alert('There was an error fetching your accounts.');
            return;
          }
          if (accs.length === 0) {
            alert('Couldn\'t get any accounts! Make sure your Ethereum client is configured correctly.');
            return;
          }
          resolve(accs);
        });
      }) as Array<string>;
    }
    return Promise.resolve(this._accounts);
   }

   private async getAccount(): Promise<string> {
    if (this._account == null) {
      this._account = await new Promise((resolve, reject) => {
        this._web3.eth.getAccounts((err, accs) => {
          if (err != null) {
            alert('There was an error fetching your accounts.');
            return;
          }
          if (accs.length === 0) {
            alert('Couldn\'t get any accounts! Make sure your Ethereum client is configured correctly.');
            return;
          }
          resolve(accs[0]);
        });
      }) as string;
      this._web3.eth.defaultAccount = this._account;
    }
    return Promise.resolve(this._account);
  }

  public async getBark(): Promise<string> {
    const account = await this.getAccount();
    return new Promise((resolve, reject) => {
      const _web3 = this._web3;
      this._tokenContract.bark.call(function (err, result) {
        if (err != null) {
          reject(err);
        }
        resolve((result));
      });
    }) as Promise<string>;
  }

  public async setText(text: string) {
    this._tokenContract.setText(text, {from: await this.getAccount()}, (err, result) => {});
  }

  public async getText(): Promise<any> {
    return new Promise((resolve, reject) => {
      this._tokenContract.text.call((err, result) => {
        if (err != null) {
          reject(err);
        }
        resolve((result));
      });
    });
  }
}
