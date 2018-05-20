import { Router } from '@angular/router';
import { SocketService } from './socket.service';
import { Component, OnInit } from '@angular/core';
import { ContractsService } from './contracts.service';
import { MatDialog, MAT_DIALOG_DATA, MatDialogRef } from '@angular/material';
import { Inject } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  public accounts: Array<string>;
  public ioConnection: any;

  constructor(private router: Router,
              private contractsService: ContractsService,
              private socketService: SocketService,
              public dialog: MatDialog) {}

  ngOnInit(): void {
    this.initIoConnection();
  }

  openDialog(message): void {
    const dialogRef = this.dialog.open(Dialog, {
      data: { address: message.replace('add_me:', ''); }
    });

    dialogRef.afterClosed().subscribe(result => {
      if(result === true) {
        console.log('ADDD');
        this.socketService.send('added');
      }
    });
  }

  private initIoConnection(): void {
    this.socketService.initSocket();

    this.socketService.onMessage()
      .subscribe((message: string) => {
        if (window.location.href.indexOf('home') > -1 && message !== 'added') {
          console.log('no to ja Cie dodam! ', message);
          this.openDialog(message);
        } else if (message === 'added') {
          this.router.navigate(['/home']);
        }
      });

    this.socketService.onConnection()
      .subscribe(() => {
        console.log('connected');
      });

    this.socketService.onDisconnected()
      .subscribe(() => {
        console.log('disconnected');
      });
  }
}

@Component({
  selector: 'app-dialog',
  templateUrl: 'app-dialog.html',
})
export class Dialog {

  constructor(
    public dialogRef: MatDialogRef<Dialog>,
    @Inject(MAT_DIALOG_DATA) public data: any) { }

  onNoClick(): void {
    this.dialogRef.close();
  }

}

