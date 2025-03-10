# Email

This deployment creates an internal mail transfer agenr using [KumoMTA](https://github.com/KumoCorp/kumomta). It allows email to be sent from within the cluster to the outside world. Specifically, it only allows sending emails from the `ieeetamu.org` domain. If an email is sent to an `@tamu.edu` address, it will forwarded it directly to the on-campus relays. If an email is sent to anywhere else, it gets sent through [brevo](https://www.brevo.com/) which allows 300 outgoing emails per day for free.

Note: the mailserver is only accessible from within the cluster. It is not exposed to the internet, the TAMU network, or even the IEEE TAMU internal network.