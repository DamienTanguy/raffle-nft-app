<template>
  <div class="app">
    <div class="container">
      <p class="error" id="error" v-if="error !== '' ">{{ error }}</p>
      <p class="success" id="success" v-if="success !== '' ">{{ success }}</p>
      <h1>Mint your NFT if you are on the whitelist:</h1>
      <p class="cost">Each NFT costs {{ price / 10**18}} eth (without gas fees)</p>
      <button id="mint" @click="mint">Buy your NFT</button>
      <p>Contract: <span id="contractAddress">{{ contractAddress }}</span></p>
    </div>
  </div>
</template>

<script>
import { ethers } from 'ethers';
import ERC721Merkle from '@/artifacts/contracts/ERC721Merkle.sol/ERC721Merkle.json';
import { MerkleTree } from 'merkletreejs';
import keccak256 from 'keccak256';
import tokens from '@/assets/tokens.json';

export default {
  name: 'RaffleNFT',
  data() {
    return {
      contractAddress: '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0',
      account: '',
      price: 0,
      error: '',
      success: ''
    }
  },
  mounted(){
    this.getAccount();
    this.getprice();
  },
    methods: {
    getAccount: async function(){
      if(typeof window.ethereum !== 'undefined') {
        const accounts = await window.ethereum.request({method : 'eth_requestAccounts'});
        this.account = accounts[0];
      }
    },
    getprice: async function(){
      if(typeof window.ethereum !== 'undefined') {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const contract = new ethers.Contract(this.contractAddress, ERC721Merkle.abi, provider); //new instance of the contract to interact with the function of the contract
        try {
          const price = await contract.getPrice();
          this.price = price;
        }
        catch(err) {
          console.log(err);
          this.setError('An error occured to get the price');
        }
      }
    },
    mint: async function(){
      if(typeof window.ethereum !== 'undefined') {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(this.contractAddress, ERC721Merkle.abi, signer);

        let tab = [];
        tokens.map(token => {
          tab.push(token.address);
        });
        const leaves = tab.map(address => keccak256(address));
        const tree = new MerkleTree(leaves, keccak256, { sort: true});
        const leaf = keccak256(this.account);
        const proof = tree.getHexProof(leaf);

        try {
          let overrides = {
            from: this.account,
            value: String(this.price)
          }
          const transaction = await contract.mintNFT(this.account, proof, overrides);
          await transaction.wait();
          this.setSuccess('The mint of your NFT is successful');
        }
        catch(err) {
          console.log(err);
          this.setError('Sorry, You are not on the whitelist');
        }
      }
    },
    setError: async function(message){
      this.error = message;
    },
    setSuccess: async function(message){
      this.success = message;
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

body {
  background-color: #393E45;
    color: #D1D5DE;
}

.app {
  text-align: center;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
}

.container {
  width: 100%;
  max-width: 960px;
  margin: 0 auto;
  padding-left: 1rem;
  padding-right: 1rem;
}

button {
  background: rgb(255, 217, 0);
  padding: 1rem 2rem;
  border-radius: 20px;
  font-weight: 700;
  border: 0;
  cursor: pointer;
}

.error, .success {
  padding: 1rem;
  margin-top: 1rem;
  border-radius: 5px;
}

.error {
  background-color: #EE3312;
  color: #D1D5DE;
}

.success {
  background-color: #53814D;
  color: #D1D5DE;
}

</style>
