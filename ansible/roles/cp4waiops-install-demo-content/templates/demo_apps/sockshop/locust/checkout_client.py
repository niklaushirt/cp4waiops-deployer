from locust import HttpUser, task, between
from util import AuthorizedClient

# Workload of a client invoking the most complex trace in SockShop, namely
# checkout. This workload skips all requests to the frontend for static
# content, because we are only interested in the performance of the actual
# checkout workflow.
class CheckoutClient(AuthorizedClient):
    wait_time = between(1, 2)
    product_id = "3395a43e-2d88-40de-b95f-e00e1502085b"

    # Add a product to the cart, which we can subsequently purchase. Making an
    # order does not actually purge the cart, so we can keep ordering the same
    # item.
    def on_start(self):
        super().on_start()

        self.client.delete("/cart")
        self.client.post("/cart", json={
            "id": CheckoutClient.product_id,
        })

    @task
    def checkout(self):
        # This initiates the most complex workflow in SockShop
        self.client.post("/orders")
