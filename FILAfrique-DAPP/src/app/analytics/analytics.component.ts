import { Component, OnInit } from '@angular/core';
import { ConfirmationService, MenuItem } from 'primeng/api';
import { chains, IChains } from '../models/Chains.model';

@Component({
  selector: 'app-analytics',
  templateUrl: './analytics.component.html',
  styleUrls: ['./analytics.component.css']
})
export class AnalyticsComponent implements OnInit {

  chains: IChains[] = chains;
  queries: MenuItem[] = [
    {
      label: "Query DEX liquidity over past 30 days",
      icon:"pi pi-chart-line",
      command: () => {
        this.query();
      }
    },
    {
      label: "Query DEX transactions",
      icon:"pi pi-list",
      command: () => {
        this.query();
      }
    },
    {
      label: "Query Stablecoin balance by wallet",
      icon:"pi pi-money-bill",
      command: () => {
        this.query();
      }
    },
    {
      label: "Query Stablecoin contract transactions",
      icon: "pi pi-list",
      command: () => {
        this.query();
      }
    },
    {
      label: "Query Stablecoin contract metadata",
      icon: "pi pi-database",
      command: () => {
        this.query();
      }
    },
    {
      label: "Query DEX proof of liquidity reserve",
      icon: "pi pi-wallet",
      command: () => {
        this.query();
      }
    }
  ]

  constructor(private confirmationService:ConfirmationService) { }

  ngOnInit(): void {
  }

  query(){
    console.log("Query called")
    this.confirmationService.confirm({
      header: "Loading data",
      message: "Please wait, data loading from Moralis and Covalent.",
      accept: ()=>{},
      acceptLabel: "OK",
      acceptIcon: "pi pi-thumbs-up",
      dismissableMask: false,
      rejectVisible: false,
      closeOnEscape: false,
    })
  }

}
