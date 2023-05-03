from locust import HttpUser, task, between
from util import AuthorizedClient

# Workload of a client invoking a simple trace with minimal services involved.
# This workload skips all requests to the frontend for static content, because
# we are only interested in the performance of the actual cart workflow.
class CartClient(AuthorizedClient):
    wait_time = between(1, 2)
    product_id = "3395a43e-2d88-40de-b95f-e00e1502085b"

    # Add a product to the cart, which we can subsequently query.
    def on_start(self):
        super().on_start()

        self.client.delete("/cart")
        self.client.post("/cart", json={
            "id": CartClient.product_id,
        })

    @task
    def checkout(self):
        self.client.get("/cart")
