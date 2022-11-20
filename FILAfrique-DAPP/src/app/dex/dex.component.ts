import { Component, OnInit } from '@angular/core';
import { ConfirmationService } from 'primeng/api';
import { Token } from '../models/Token.model';
import { TokenService } from '../services/token.service';

import { chains, IChains } from '../models/Chains.model';
import { Router } from '@angular/router';


@Component({
  selector: 'app-dex',
  templateUrl: './dex.component.html',
  styleUrls: ['./dex.component.css']
})
export class DexComponent implements OnInit {

  walletConnected: boolean = false;
  walletAddress: string = "";
  Tokens: Token[] = []

  _fromAmount: any = 10;
  _toAmount: any = 0;

  selectedFromToken: any = "";
  selectedToToken:any = "";

  canSwap:boolean = false;

  chainSelected: boolean = false;
  chain: any;
  CHAINS: any = [];

  constructor(private tokenService: TokenService, private confirmationService:ConfirmationService, private router:Router) { 
    
  }

  ngOnInit(): void {
    this.CHAINS = chains
  }

  async connectWallet() {
    this.confirmationService.confirm({
      header: "Connect wallet to proceed!",
      message: "Please make sure you connect to the correct chain",
      accept: async () => {
        if (typeof window.ethereum !== 'undefined') {
          console.log('MetaMask is installed!');
          const accounts = await window.ethereum.request({method: 'eth_requestAccounts'}).catch((err:any) => {
            if (err.code === 4001){
              this.confirmationService.confirm({
                header: "Connect wallet to proceed!",
                message: "You need to connect your wallet to use the DEX",
                accept: () => {},
                acceptLabel: "OK",
                acceptIcon: "pi pi-thumbs-up",
                dismissableMask: false,
                rejectVisible: false,
                closeOnEscape: false,
              })
            }
          });
          this.walletAddress = accounts[0];
          console.log(this.walletAddress);
          this.walletConnected = true;
        }
      },
      acceptLabel: "OK",
      acceptIcon: "pi pi-thumbs-up",
      dismissableMask: false,
      rejectVisible: false,
      closeOnEscape: false,
    })
    
  }

  continueToSwap(){
    console.log(this.chain)
    if (this.chain != ""){
      this.chainSelected = true;
      this.Tokens = this.tokenService.getTokens(this.chain.name);
    }
  }

  async calculateSwap(){
    console.log("Logging selected from token: ", this.selectedFromToken);
    console.log("Logging selected to token: ", this.selectedToToken);
    console.log("Logging base token amount: ", this._fromAmount);
    if(this.selectedFromToken == this.selectedToToken){
      console.log("Logging to and from are the same");
      this.confirmationService.confirm({
        header: "Invalid swappp!",
        message: "You cannot swappp to and from the same token. Kindly select a  different token than the one you intend on swappping.",
        accept: () => {},
        acceptLabel: "OK",
        acceptIcon: "pi pi-thumbs-up",
        dismissableMask: false,
        rejectVisible: false,
        closeOnEscape: false,
      })
    }
    else {
      const resp = this.tokenService.getRate(this.chain.contracts.dex,this.selectedToToken.tokenName.toLowerCase());
      console.log("resp: ", typeof(resp))
      console.log("_from: ", typeof(this._fromAmount))
      console.log("_to: ", typeof(this._toAmount))
      this._toAmount = this._fromAmount * await resp/1**18
      console.log(this._toAmount);
      this.canSwap = true;
    }
  }

  async swapTokens(){
    if (this.chain.name == "Filcoin"){
      const resp = await this.tokenService.executeSwap(this.chain.contracts.dex,this.selectedToToken.tokenName.toLowerCase(), this._fromAmount);
      console.log(resp);
      this.confirmationService.confirm({
        header: "Swappp complete",
        message: "View the transaction on the testnet explorer",
        accept: () => {},
        acceptLabel: "Ok",
        acceptIcon: "pi pi-thumbs-up",
        dismissableMask: false,
        rejectVisible: false,
        closeOnEscape: false,
      })
    }
  }
  

  goToAnalytics(){
    this.router.navigateByUrl("0xAfrica/analytics");
  }

}
