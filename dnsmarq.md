<h1 class="code-line" data-line-start=2 data-line-end=3 ><a id="Local_DNS_Setup_on_Rocky_Linux_2"></a>Local DNS Setup on Rocky Linux</h1>
<p class="has-line-data" data-line-start="4" data-line-end="6"><a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a><br>
<a href="https://github.com/yourusername/yourrepository"><img src="https://img.shields.io/badge/build-passing-brightgreen.svg" alt="Build Status"></a></p>
<p class="has-line-data" data-line-start="7" data-line-end="8">This guide explains how to configure a local DNS solution on <strong>Rocky Linux</strong> using <strong>DNSMasq</strong> and <strong>BIND</strong>. It covers:</p>
<ul>
<li class="has-line-data" data-line-start="9" data-line-end="10"><strong>DNSMasq:</strong> Serves local DNS records.</li>
<li class="has-line-data" data-line-start="10" data-line-end="11"><strong>BIND:</strong> Acts as a full recursive resolver on an alternate port (5300) for external queries.</li>
<li class="has-line-data" data-line-start="11" data-line-end="13"><strong>System Resolver:</strong> Configured to use the local DNS (DNSMasq) exclusively.</li>
</ul>
<blockquote>
<p class="has-line-data" data-line-start="13" data-line-end="14"><strong>Note:</strong> Since DNSMasq uses port 53, BIND must run on port 5300 to avoid conflicts.</p>
</blockquote>
<hr>
<h2 class="code-line" data-line-start=17 data-line-end=18 ><a id="Table_of_Contents_17"></a>Table of Contents</h2>
<ul>
<li class="has-line-data" data-line-start="19" data-line-end="20"><a href="#1-update-your-system">1. Update Your System</a></li>
<li class="has-line-data" data-line-start="20" data-line-end="21"><a href="#2-install--configure-dnsmasq">2. Install &amp; Configure DNSMasq</a></li>
<li class="has-line-data" data-line-start="21" data-line-end="22"><a href="#3-enable-external-dns-resolution-temporarily">3. Enable External DNS Resolution Temporarily</a></li>
<li class="has-line-data" data-line-start="22" data-line-end="23"><a href="#4-install--configure-bind">4. Install &amp; Configure BIND</a></li>
<li class="has-line-data" data-line-start="23" data-line-end="24"><a href="#5-configure-bind-as-a-recursive-resolver-on-port-5300">5. Configure BIND as a Recursive Resolver on Port 5300</a></li>
<li class="has-line-data" data-line-start="24" data-line-end="25"><a href="#6-restore-local-dns-resolution">6. Restore Local DNS Resolution</a></li>
<li class="has-line-data" data-line-start="25" data-line-end="26"><a href="#7-testing-the-setup">7. Testing the Setup</a></li>
<li class="has-line-data" data-line-start="26" data-line-end="27"><a href="#8-configure-the-firewall">8. Configure the Firewall</a></li>
<li class="has-line-data" data-line-start="27" data-line-end="29"><a href="#9-summary">9. Summary</a></li>
</ul>
<hr>
<h2 class="code-line" data-line-start=31 data-line-end=32 ><a id="1_Update_Your_System_31"></a>1. Update Your System</h2>
<p class="has-line-data" data-line-start="33" data-line-end="34">Ensure your system is up to date:</p>
<pre><code class="has-line-data" data-line-start="36" data-line-end="38" class="language-bash">sudo yum update -y
</code></pre>
<hr>
<h2 class="code-line" data-line-start=41 data-line-end=42 ><a id="2_Install__Configure_DNSMasq_41"></a>2. Install &amp; Configure DNSMasq</h2>
<h3 class="code-line" data-line-start=43 data-line-end=44 ><a id="Install_DNSMasq_43"></a>Install DNSMasq</h3>
<pre><code class="has-line-data" data-line-start="46" data-line-end="51" class="language-bash">sudo yum install dnsmasq -y
sudo systemctl start dnsmasq
sudo systemctl <span class="hljs-built_in">enable</span> dnsmasq
sudo systemctl status dnsmasq
</code></pre>
<p class="has-line-data" data-line-start="52" data-line-end="53">Backup the default configuration:</p>
<pre><code class="has-line-data" data-line-start="55" data-line-end="57" class="language-bash">sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
</code></pre>
<h3 class="code-line" data-line-start=58 data-line-end=59 ><a id="Configure_DNSMasq_58"></a>Configure DNSMasq</h3>
<p class="has-line-data" data-line-start="60" data-line-end="61">Open the configuration file:</p>
<pre><code class="has-line-data" data-line-start="63" data-line-end="65" class="language-bash">sudo vi /etc/dnsmasq.conf
</code></pre>
<p class="has-line-data" data-line-start="66" data-line-end="67">Add these lines to define your local DNS record and set up forwarding:</p>
<pre><code class="has-line-data" data-line-start="69" data-line-end="78" class="language-conf"># Local DNS record for ns5.jeebr.net
address=/ms5.mahendranath.com/189.781.452.201

# Do not use external nameservers from /etc/resolv.conf
no-resolv

# Forward unresolved queries to BIND on port 5300
server=127.0.0.1#5300
</code></pre>
<p class="has-line-data" data-line-start="79" data-line-end="80">Test and restart DNSMasq:</p>
<pre><code class="has-line-data" data-line-start="82" data-line-end="85" class="language-bash">sudo dnsmasq --test
sudo systemctl restart dnsmasq
</code></pre>
<hr>
<h2 class="code-line" data-line-start=88 data-line-end=89 ><a id="3_Enable_External_DNS_Resolution_Temporarily_88"></a>3. Enable External DNS Resolution Temporarily</h2>
<p class="has-line-data" data-line-start="90" data-line-end="91">If external DNS isn’t working (needed for package installation), update <code>/etc/resolv.conf</code>:</p>
<pre><code class="has-line-data" data-line-start="93" data-line-end="95" class="language-bash">sudo vi /etc/resolv.conf
</code></pre>
<p class="has-line-data" data-line-start="96" data-line-end="97">Replace its contents with:</p>
<pre><code class="has-line-data" data-line-start="99" data-line-end="101" class="language-conf">nameserver 8.8.8.8
</code></pre>
<p class="has-line-data" data-line-start="102" data-line-end="103">Test external DNS:</p>
<pre><code class="has-line-data" data-line-start="105" data-line-end="107" class="language-bash">nslookup mirrors.rockylinux.org
</code></pre>
<hr>
<h2 class="code-line" data-line-start=110 data-line-end=111 ><a id="4_Install__Configure_BIND_110"></a>4. Install &amp; Configure BIND</h2>
<h3 class="code-line" data-line-start=112 data-line-end=113 ><a id="Install_BIND_and_BindUtils_112"></a>Install BIND and Bind-Utils</h3>
<pre><code class="has-line-data" data-line-start="115" data-line-end="117" class="language-bash">sudo yum install -y <span class="hljs-built_in">bind</span> <span class="hljs-built_in">bind</span>-utils
</code></pre>
<hr>
<h2 class="code-line" data-line-start=120 data-line-end=121 ><a id="5_Configure_BIND_as_a_Recursive_Resolver_on_Port_5300_120"></a>5. Configure BIND as a Recursive Resolver on Port 5300</h2>
<p class="has-line-data" data-line-start="122" data-line-end="123">Edit the main BIND configuration file:</p>
<pre><code class="has-line-data" data-line-start="125" data-line-end="127" class="language-bash">sudo vi /etc/named.conf
</code></pre>
<p class="has-line-data" data-line-start="128" data-line-end="129">Replace or modify the options block as follows (adjust the local network range if needed):</p>
<pre><code class="has-line-data" data-line-start="131" data-line-end="165" class="language-conf">options {
    /* Listen on port 5300 instead of 53 */
    listen-on port 5300 { 127.0.0.1; };
    listen-on-v6 port 5300 { ::1; };

    directory       &quot;/var/named&quot;;
    dump-file       &quot;/var/named/data/cache_dump.db&quot;;
    statistics-file &quot;/var/named/data/named_stats.txt&quot;;
    memstatistics-file &quot;/var/named/data/named_mem_stats.txt&quot;;
    secroots-file   &quot;/var/named/data/named.secroots&quot;;
    recursing-file  &quot;/var/named/data/named.recursing&quot;;

    /* Allow queries from localhost and local network */
    allow-query     { localhost; 192.168.1.0/24; };

    /* Allow recursion for trusted clients */
    allow-recursion { 127.0.0.1; 192.168.1.0/24; };

    /* Enable full recursion (no forwarders) */
    recursion yes;
    forwarders { };

    dnssec-enable yes;
    dnssec-validation yes;

    managed-keys-directory &quot;/var/named/dynamic&quot;;

    pid-file &quot;/run/named/named.pid&quot;;
    session-keyfile &quot;/run/named/session.key&quot;;

    /* Use system crypto policy */
    include &quot;/etc/crypto-policies/back-ends/bind.config&quot;;
};
</code></pre>
<p class="has-line-data" data-line-start="166" data-line-end="167">Enable and start BIND:</p>
<pre><code class="has-line-data" data-line-start="169" data-line-end="172" class="language-bash">sudo systemctl <span class="hljs-built_in">enable</span> --now named
sudo systemctl status named
</code></pre>
<p class="has-line-data" data-line-start="173" data-line-end="174">Verify BIND is listening on port 5300:</p>
<pre><code class="has-line-data" data-line-start="176" data-line-end="178" class="language-bash">sudo ss -tunlp | grep <span class="hljs-number">5300</span>
</code></pre>
<hr>
<h2 class="code-line" data-line-start=181 data-line-end=182 ><a id="6_Restore_Local_DNS_Resolution_181"></a>6. Restore Local DNS Resolution</h2>
<p class="has-line-data" data-line-start="183" data-line-end="184">After configuring DNSMasq and BIND, set your system to use only the local DNS server.</p>
<h3 class="code-line" data-line-start=185 data-line-end=186 ><a id="Update_etcresolvconf_185"></a>Update <code>/etc/resolv.conf</code></h3>
<pre><code class="has-line-data" data-line-start="188" data-line-end="190" class="language-bash">sudo vi /etc/resolv.conf
</code></pre>
<p class="has-line-data" data-line-start="191" data-line-end="192">Replace the file’s content with:</p>
<pre><code class="has-line-data" data-line-start="194" data-line-end="197" class="language-conf">search mahendranath.com
nameserver 127.0.0.1
</code></pre>
<h3 class="code-line" data-line-start=198 data-line-end=199 ><a id="Prevent_Overwrites_by_NetworkManager_198"></a>Prevent Overwrites by NetworkManager</h3>
<h4 class="code-line" data-line-start=200 data-line-end=201 ><a id="Option_A_Modify_NetworkManagers_Configuration_200"></a>Option A: Modify NetworkManager’s Configuration</h4>
<pre><code class="has-line-data" data-line-start="203" data-line-end="205" class="language-bash">sudo vi /etc/NetworkManager/NetworkManager.conf
</code></pre>
<p class="has-line-data" data-line-start="206" data-line-end="207">Add or update the <code>[main]</code> section:</p>
<pre><code class="has-line-data" data-line-start="209" data-line-end="212" class="language-ini"><span class="hljs-title">[main]</span>
<span class="hljs-setting">dns=<span class="hljs-value">none</span></span>
</code></pre>
<p class="has-line-data" data-line-start="213" data-line-end="214">Restart NetworkManager:</p>
<pre><code class="has-line-data" data-line-start="216" data-line-end="218" class="language-bash">sudo systemctl restart NetworkManager
</code></pre>
<h4 class="code-line" data-line-start=219 data-line-end=220 ><a id="Option_B_Lock_the_File_219"></a>Option B: Lock the File</h4>
<p class="has-line-data" data-line-start="221" data-line-end="222">Lock <code>/etc/resolv.conf</code> to prevent changes:</p>
<pre><code class="has-line-data" data-line-start="224" data-line-end="226" class="language-bash">sudo chattr +i /etc/resolv.conf
</code></pre>
<p class="has-line-data" data-line-start="227" data-line-end="228"><em>To edit later, unlock with:</em></p>
<pre><code class="has-line-data" data-line-start="230" data-line-end="232" class="language-bash">sudo chattr -i /etc/resolv.conf
</code></pre>
<hr>
<h2 class="code-line" data-line-start=235 data-line-end=236 ><a id="7_Testing_the_Setup_235"></a>7. Testing the Setup</h2>
<h3 class="code-line" data-line-start=237 data-line-end=238 ><a id="Test_Local_DNS_Resolution_237"></a>Test Local DNS Resolution</h3>
<pre><code class="has-line-data" data-line-start="240" data-line-end="242" class="language-bash">nslookup ms5.mahendranath.com
</code></pre>
<p class="has-line-data" data-line-start="243" data-line-end="244"><em>Expected output:</em></p>
<pre><code class="has-line-data" data-line-start="246" data-line-end="249">Name: ms5.mahendranath.com
Address: 189.781.452.201
</code></pre>
<h3 class="code-line" data-line-start=250 data-line-end=251 ><a id="Test_External_DNS_Resolution_250"></a>Test External DNS Resolution</h3>
<p class="has-line-data" data-line-start="252" data-line-end="253">Using <code>nslookup</code>:</p>
<pre><code class="has-line-data" data-line-start="255" data-line-end="257" class="language-bash">nslookup yahoo.com <span class="hljs-number">127.0</span>.<span class="hljs-number">0.1</span>
</code></pre>
<p class="has-line-data" data-line-start="258" data-line-end="259">Or using <code>dig</code>:</p>
<pre><code class="has-line-data" data-line-start="261" data-line-end="263" class="language-bash">dig @<span class="hljs-number">127.0</span>.<span class="hljs-number">0.1</span> yahoo.com
</code></pre>
<p class="has-line-data" data-line-start="264" data-line-end="265"><em>DNSMasq should forward external queries to BIND (on port 5300), which then performs the resolution.</em></p>
<hr>
<h2 class="code-line" data-line-start=268 data-line-end=269 ><a id="8_Configure_the_Firewall_268"></a>8. Configure the Firewall</h2>
<p class="has-line-data" data-line-start="270" data-line-end="271">If firewalld is active, allow DNS and DHCP traffic:</p>
<pre><code class="has-line-data" data-line-start="273" data-line-end="277" class="language-bash">sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --add-service=dhcp --permanent
sudo firewall-cmd --reload
</code></pre>
<hr>
<h2 class="code-line" data-line-start=280 data-line-end=281 ><a id="9_Summary_280"></a>9. Summary</h2>
<ul>
<li class="has-line-data" data-line-start="282" data-line-end="283"><strong>DNSMasq</strong> runs on port <strong>53</strong> to handle local DNS entries (e.g., <code>ns5.jeebr.net</code>) and forwards unresolved queries.</li>
<li class="has-line-data" data-line-start="283" data-line-end="284"><strong>BIND</strong> operates as a full recursive resolver on <strong>127.0.0.1:5300</strong>.</li>
<li class="has-line-data" data-line-start="284" data-line-end="285">The system resolver (<code>/etc/resolv.conf</code>) is set to use the local DNS server, ensuring that all queries are processed locally.</li>
<li class="has-line-data" data-line-start="285" data-line-end="287">NetworkManager settings (or file locking) prevent DNS configuration from being overwritten.</li>
</ul>
<hr>
<p class="has-line-data" data-line-start="289" data-line-end="290">.</p>
