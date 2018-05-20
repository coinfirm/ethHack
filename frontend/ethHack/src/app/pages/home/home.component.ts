import { Component } from '@angular/core';
import { ContractsService } from '../../contracts.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent {
  public keys = [];
  public balances = [];
  public balance: string;

  constructor(private contractsService: ContractsService) {
    this.contractsService.keysSize().then(size => {
      for (let i = 0; i < parseInt(size, 10); i++) {
        const key = this.getKey(i).then(res => {
          this.keys.push(res);
          this.balances.push(this.contractsService.getBalance(res));
        });
      }
    });
    this.contractsService.getMyBalance().then(balance => {
      this.balance = balance;
    });
  }

  private getKey(index): Promise<string> {
    return new Promise((resolve, reject) => {
      this.contractsService.getKey(index).then((key) => {
        resolve(key);
      });
    });
  }

  public async delete(index: number) {
    await this.contractsService.removeKey(index);
    this.keys.splice(index, 1);
    //location.reload();
  }
}
