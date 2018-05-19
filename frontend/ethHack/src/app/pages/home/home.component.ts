import { Component } from '@angular/core';
import { ContractsService } from '../../contracts.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  // styleUrls: ['./home.component.scss']
})
export class HomeComponent {
  public bark: string;
  public text: string;
  public accounts: Array<string>;

  constructor(contractsService: ContractsService) {}
}
