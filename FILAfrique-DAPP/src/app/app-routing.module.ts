import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AnalyticsComponent } from './analytics/analytics.component';
import { DexComponent } from './dex/dex.component';
import { HomepageComponent } from './homepage/homepage.component';

const routes: Routes = [
  {
    path: "",
    pathMatch: 'full',
    redirectTo: "0xAfrica/home"
  },
  {
    path: "0xAfrica/home",
    component: HomepageComponent
  },
  {
    path: "0xAfrica/dex",
    component: DexComponent
  },
  {
    path: "0xAfrica/analytics",
    component: AnalyticsComponent
  },
  {
    path: "**/**",
    component: HomepageComponent
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
