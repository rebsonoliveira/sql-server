<Query Kind="Expression">
  <Connection>
    <ID>0a98b0bc-4850-40e5-9b82-0a5339b19c5f</ID>
    <Persist>true</Persist>
    <Driver Assembly="OData4DynamicDriver" PublicKeyToken="ac4f2d9e4b31c376">OData4.OData4DynamicDriver</Driver>
    <Server>http://localhost:59934/api/odata</Server>
  </Connection>
</Query>

People
.Where(p=>p.id<50 && p.id>5)
.OrderBy(p=>p.town)
.Select(p=>new {p.id,p.name,p.town})