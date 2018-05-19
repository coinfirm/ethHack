import { Component } from '@angular/core';
import { ContractsService } from '../../contracts.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {
  public done = false;
  public loading = false;

  constructor(contractsService: ContractsService) {
  }

  public doneClick() {
    this.loading = true;
    setTimeout(() => {
      this.loading = false;
      this.done = true;
    }, 2000);
  }
}
