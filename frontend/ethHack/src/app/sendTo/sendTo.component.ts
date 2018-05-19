import { ContractsService } from './../contracts.service';
import { Component } from '@angular/core';

@Component({
  selector: 'app-send-to',
  templateUrl: './sendTo.component.html',
  styleUrls: ['./sendTo.component.scss']
})
export class SendToComponent {

  public recipientAddress: string;
  public value: string;

  constructor(private contractsService: ContractsService) {}

  public sendValue() {
    this.contractsService.executeSign(this.recipientAddress, parseInt(this.value, 10));
  }
}
