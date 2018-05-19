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

  constructor(private router: Router, contractsService: ContractsService) {
  }

  public doneClick() {
    this.loading = true;
    setTimeout(() => {
      this.loading = false;
      this.done = true;
      setTimeout(() => {
        this.router.navigate(['/home']);
      }, 1500);
    }, 2000);
  }
}
