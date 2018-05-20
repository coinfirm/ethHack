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

  public async sendValue() {
    await this.contractsService.sendEther(this.recipientAddress, parseInt(this.value, 10));
    //location.reload();
  }
}
