import { Component } from '@angular/core';
import { ContractsService } from '../../contracts.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent {
  public keys = [];
  public balance: string;

  constructor(private contractsService: ContractsService) {
    this.contractsService.keysSize().then(size => {
      for (let i = 0; i < parseInt(size, 10); i++) {
        this.keys.push(this.getKey(i));
      }
    });
    this.contractsService.getBalance().then(balance => {
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
