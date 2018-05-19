import { Component } from '@angular/core';
import { ContractsService } from '../../contracts.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {
  public done = false;
  public loading = false;
  public error = false;
  public key: string;

  constructor(private router: Router, private contractsService: ContractsService) {
    this.contractsService.getKey(0).then((key) => {
      console.log('key0: ', key);
    });
    this.contractsService.getKey(1).then((key) => {
      console.log('key1: ', key);
    });
    this.contractsService.getKey(2).then((key) => {
      console.log('key2: ', key);
    });
  }

  public doneClick() {
    this.loading = true;
    this.error = false;
    this.contractsService.keysSize().then((size) => {
      for (let i = 0; i < parseInt(size, 10); i++) {
        this.getKey(i).then((key) => {
          if (key === this.key) {
            this.loading = false;
            this.done = true;
            setTimeout(() => {
              // this.router.navigate(['/home']);
            }, 1500);
          } else if ((key === '0x0000000000000000000000000000000000000000' || i === (parseInt(size, 10) - 1)) && !this.done) {
            this.error = true;
            this.loading = false;
          }
        });
      }
    });
  }

  private getKey(index): Promise < string > {
  return new Promise((resolve, reject) => {
    this.contractsService.getKey(index).then((key) => {
      resolve(key);
    });
  });
}

  public add() {
    this.contractsService.executeSign('0x4E90a36B45879F5baE71B57Ad525e817aFA54890');
  }
}
