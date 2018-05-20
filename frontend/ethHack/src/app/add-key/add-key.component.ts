import { Component } from '@angular/core';
import { ContractsService } from './../contracts.service';
@Component({
  selector: 'app-add-key',
  templateUrl: './add-key.component.html',
  styleUrls: ['./add-key.component.scss']
})
export class AddKeyComponent {

  public key: string;

  constructor(private contractsService: ContractsService) { }

  public addKey() {
    console.log(this.key);
    this.contractsService.addKey(this.key);
  }
}
