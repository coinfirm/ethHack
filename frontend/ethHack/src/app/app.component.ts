import { Component } from '@angular/core';
import { ContractsService } from './contracts.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  public bark: string;
  public text: string;
  public accounts: Array<string>;

  constructor(contractsService: ContractsService) {
    // contractsService.test();
    // contractsService.getBark().then(bark => {
    //   contractsService.test();
    //   this.bark = bark;
    // });
    // // contractsService.setText('dupax');
    // contractsService.getText().then(text => this.text = text);
    // contractsService.getAccounts().then(accs => this.accounts = accs);
  }
}
