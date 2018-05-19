import { Component } from '@angular/core';
import { ContractsService } from '../../contracts.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {
  public bark: string;
  public text: string;
  public accounts: Array<string>;

  constructor(contractsService: ContractsService) {}
}
