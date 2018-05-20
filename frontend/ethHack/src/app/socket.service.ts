
import { Injectable } from '@angular/core';
import { Observable, Observer } from 'rxjs';

import * as socketIo from 'socket.io-client';

const SERVER_URL = 'http://54.37.16.205:8080';

@Injectable({
  providedIn: 'root'
})
export class SocketService {
    private socket;

    public initSocket(): void {
        this.socket = socketIo(SERVER_URL);
    }

    public send(message: string): void {
        this.socket.emit('message', message);
    }

    public onMessage(): Observable<string> {
        return new Observable<string>(observer => {
            this.socket.on('message', (data: string) => observer.next(data));
        });
    }

    public onConnection(): Observable<any> {
        return new Observable<Event>(observer => {
            this.socket.on('connection', () => observer.next());
        });
    }

    public onDisconnected(): Observable<any> {
      return new Observable<Event>(observer => {
          this.socket.on('disconnected', () => observer.next());
      });
  }
}