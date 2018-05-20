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
  private _web3_relayer: any;

  private _tokenContract: any;
  private _tokenContractAddress = '0xd2e8d9173584d4daa5c8354a79ef75cec2dfa228'; // address from migrate trx

  constructor() {
    if (typeof window.web3 !== 'undefined') {
      // Use Mist/MetaMask's provider
      this._web3 = new Web3(window.web3.currentProvider);
      // this._web3_relayer = new Web3(new Web3.providers.HttpProvider("http://hacketh.bycode.io:8545"));
      this._web3_relayer = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
    } else {
      // this._web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
      alert('Please use a dapp browser like mist or MetaMask plugin for chrome');
    }
    this._tokenContract = this._web3_relayer.eth.contract(tokenAbi).at(this._tokenContractAddress);
  }

  public async addKey(key: string) {
    const addr = `0x5f7b68be000000000000000000000000${key.slice(2)}`;
    return await this.executeSign(this._tokenContractAddress, 0, addr);
  }

  public async removeKey(index: number) {
    const addr = `0x993be92d000000000000000000000000000000000000000000000000000000000000000${index}`;
    return await this.executeSign(this._tokenContractAddress, 0, addr);
  }

  public async sendEther(to: string, value: number) {
    return await this.executeSign(to, value * 1000000000000000000, '');
  }

  public async executeSign(to: string, value: number = 0, addr: string) {
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
            this._tokenContract.executeSigned(to, value, addr, h, v, r, s, { from: accs[0], gas: 1000000 },
              (err2, result) => {
                console.log('err: ', err2);
                console.log('execute: ', result);
              });
            resolve(accs);
          });
        });
      }) as Array<string>;
    }
  }

  public async getAccount(): Promise<string> {
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
    }
    return Promise.resolve(this._account);
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

  public async getMyBalance(): Promise<string> {
    return new Promise((resolve, reject) => {
      const _web3 = this._web3;
      this.getAccount().then(acc => {
        this._web3.eth.getBalance(acc, (err, balance) => {
          resolve((parseFloat((balance)) / 1000000000000000000).toString());
        });
      });
    }) as Promise<string>;
  }

  public async getBalance(address: string): Promise<string> {
    return new Promise((resolve, reject) => {
      const _web3 = this._web3;
      this._web3.eth.getBalance(address, (err, balance) => {
        resolve((parseFloat((balance)) / 1000000000000000000).toString());
      });
    }) as Promise<string>;
  }
}
