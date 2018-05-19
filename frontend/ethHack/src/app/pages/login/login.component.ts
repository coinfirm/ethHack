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
  }

  public doneClick() {
    this.loading = true;
    this.error = false;
    console.log('this key: ', this.key);
    this.contractsService.getKey(1).then((key) => {
      if (key === this.key) {
        this.loading = false;
        this.done = true;
        setTimeout(() => {
          this.router.navigate(['/home']);
        }, 1500);
      } else {
        this.error = true;
        this.loading = false;
      }
    });
  }

  public add() {
    this.contractsService.executeSign();
  }
}
