#!/bin/bash

BASE_URL="http://localhost:45173/api/products"

echo "---- GET all products ----"
curl -s -X GET "$BASE_URL" | jq
echo -e "\n"

echo "---- CREATE product ----"
RESPONSE_OF_CREATE=$(curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d '{"name": "Zeszyt w kratkę", "price": 6.49}')

echo $RESPONSE_OF_CREATE | jq
echo -e "\n"

PRODUCT_ID=$(echo $RESPONSE_OF_CREATE | jq -r '.id')

echo "ID of created product: $PRODUCT_ID"
echo -e "\n"

echo "---- GET product ----"
curl -s -X GET "$BASE_URL/$PRODUCT_ID" | jq
echo -e "\n"

echo "---- UPDATE product ----"
curl -s -X PUT "$BASE_URL/$PRODUCT_ID" \
  -H "Content-Type: application/json" \
  -d '{"name": "Zeszyt w kratkę PROMOCJA TYLKO TERAZ", "price": 4.99}' | jq
echo -e "\n"

echo "---- GET updated product ----"
curl -s -X GET "$BASE_URL/$PRODUCT_ID" | jq
echo -e "\n"

echo "---- DELETE product ----"
curl -s -X DELETE "$BASE_URL/$PRODUCT_ID" | jq
echo -e "\n"

echo "---- GET deleted product (should cause error 404) ----"
curl -s -X GET "$BASE_URL/$PRODUCT_ID" | jq
echo -e "\n"
