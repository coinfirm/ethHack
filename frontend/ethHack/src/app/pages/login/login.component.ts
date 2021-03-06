import { SocketService } from './../../socket.service';
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

  constructor(private router: Router,
              private contractsService: ContractsService,
              private socketService: SocketService) {
  }

  public doneClick() {
    this.loading = true;
    this.error = false;
    this.contractsService.keysSize().then((size) => {
      for (let i = 0; i < parseInt(size, 10); i++) {
        this.getKey(i).then((key) => {
          if (key.toLowerCase() === this.key.toLowerCase()) {
            this.loading = false;
            this.done = true;
            setTimeout(() => {
              this.router.navigate(['/home']);
            }, 1500);
          } else if ((key === '0x0000000000000000000000000000000000000000' || i === (parseInt(size, 10) - 1)) && !this.done) {
            this.error = true;
            this.loading = false;
          }
        });
      }
    });
  }

  public onChange() {
    this.error = false;
  }

  public signIn() {
    this.loading = true;
    this.contractsService.getAccount().then((addr) => {
      this.socketService.send(addr);
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
    this.contractsService.addKey('0x4E90a36B45879F5baE71B57Ad525e817aFA54890');
  }
}
