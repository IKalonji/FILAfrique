import { Injectable } from '@angular/core';
import { FILToken, Token } from '../models/Token.model';
import { ethers } from 'ethers';
import * as dexABI from './contractABI/DEX.ABI.json';
import * as tokenABI from './contractABI/TOKEN.ABI.json';
import {abidex} from './contractABI/DEX.ABI';
import { abitoken } from './contractABI/TOKEN.ABI';

@Injectable({
  providedIn: 'root'
})
export class TokenService {
  
  private tokens: Token[] = [];

  dexContract:any;
  tokenContract:any;
  
  constructor() {}

  getTokens(chain:string){
    this.tokens = FILToken;
    return this.tokens;
  }

  async getRate(address: string, tokenName: string){
    console.log("Logging name sent to service: ", tokenName);
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner();
    const contract: any  = new ethers.Contract(address, abidex, signer);
    const rate = await contract.getExchangeRate(tokenName);
    console.log(rate);
    return Number(rate._hex);
  }

  async executeSwap(address: string, tokenName: string, amount:number){
    const provider = new ethers.providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner();
    const contract: any  = new ethers.Contract(address, abidex, signer);
    const tx = await contract.swapToken(tokenName, {value: ethers.utils.parseEther(amount.toString())});
    const resp = await tx.wait();
    console.log(resp);
    return resp;
  }

}