import { Injectable } from '@angular/core';
import Web3 from 'web3';

declare let require: any;
declare let window: any;

const tokenAbi = require('../../../../build/contracts/ExecuteSignedMVP.json').abi;

@Injectable({
  providedIn: 'root'
})
export class ContractsService {
  private _account: string = null;
  private _accounts: Array<string> = null;
  private _web3: any;

  private _tokenContract: any;
  private _tokenContractAddress = '0xd2e8d9173584d4daa5c8354a79ef75cec2dfa228'; // address from migrate trx

  constructor() {
    if (typeof window.web3 !== 'undefined') {
      // Use Mist/MetaMask's provider
      this._web3 = new Web3(window.web3.currentProvider);
      // this._web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
    } else {
      // this._web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
      
      alert('Please use a dapp browser like mist or MetaMask plugin for chrome');
    }
    this._tokenContract = this._web3.eth.contract(tokenAbi).at(this._tokenContractAddress);
  }

  public async executeSign() {
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
          const msg = '0x8CbaC5e4d803bE2A3A5cd3DbE7174504c6DD0c1C';
          console.log('signing');
          const h = this._web3.sha3(msg);
          this._web3.eth.sign(accs[0], h, (err, sig) => {
            console.log('callback');
            console.log('err: ', err);
            console.log('sig: ', sig);
            sig = sig.slice(2);
            const r = `0x${sig.slice(0, 64)}`;
            const s = `0x${sig.slice(64, 128)}`;
            const v = this._web3.toDecimal('0x' + sig.slice(128, 130));
            sig = '0x' + sig;
            console.log({ msg, h, sig, r, s, v });
            // 'addr' to add the addr to id
            const addr = '0x4E90a36B45879F5baE71B57Ad525e817aFA54890';
             this._tokenContract.executeSigned(addr, h, v, r, s, {from: accs[0], gas: 1000000 }, (err2, result) => {
               console.log('err: ', err2);
               console.log('execute: ', result);
             });
            resolve(accs);
          });
        });
      }) as Array<string>;
    }
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

  public async getKey(index): Promise<string> {
    return new Promise((resolve, reject) => {
      const _web3 = this._web3;
      this._tokenContract.getKey.call(index, function (err, result) {
        if (err != null) {
          reject(err);
        }
        resolve((result));
      });
    }) as Promise<string>;
  }

  public async keysSize(): Promise<string> {
    return new Promise((resolve, reject) => {
      const _web3 = this._web3;
      this._tokenContract.keysSize.call(function (err, result) {
        if (err != null) {
          reject(err);
        }
        resolve((result));
      });
    }) as Promise<string>;
  }
}
