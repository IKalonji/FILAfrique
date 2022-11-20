import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { PrimeNGConfig } from 'primeng/api';


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = '0xAfrica-DEX';

  constructor(private router: Router, private primengConfig: PrimeNGConfig){}

  ngOnInit(): void {
    this.primengConfig.ripple = true;
  }

  launchDEX(){
    this.router.navigate(["0xAfrica/dex"]);
  }

  goToAnalytics(){
    this.router.navigateByUrl("0xAfrica/analytics");
  }
}
