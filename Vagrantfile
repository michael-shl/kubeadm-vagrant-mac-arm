NUM_CP_NODES=1
NUM_WORKER_NODES=2

Vagrant.configure("2") do |config|

  config.vm.box = "starboard/ubuntu-arm64-20.04.5"
  config.vm.box_version = "20221120.20.40.0"

  config.vm.provider "vmware_desktop" do |v|
    v.gui = true
    v.linked_clone = false
    v.vmx["ethernet0.virtualdev"] = "vmxnet3"
  end

  (1..NUM_CP_NODES).each do |i|

  config.vm.define "cp#{i}" do |cp|

    cp.vm.hostname = "cp#{i}"
    cp.vm.provision "file", source: "files/kubeadm-config.yaml", destination: "kubeadm-config.yaml"
    cp.vm.provision "file", source: "files/calico.yaml", destination: "calico.yaml"

    cp.vm.provider "vmware_desktop" do |v|
      v.vmx["memsize"] = 4096
      v.vmx["numvcpus"] = 3
    end

    cp.vm.provision "shell", path: "scripts/common.sh"
    cp.vm.provision "shell", path: "scripts/cp.sh"
  end
  end

  (1..NUM_WORKER_NODES).each do |i|

  config.vm.define "worker#{i}" do |worker|
    worker.vm.hostname = "worker#{i}"
    worker.vm.provision "file", source: "files/kubeadm-config.yaml", destination: "kubeadm-config.yaml"
    worker.vm.provision "file", source: "files/calico.yaml", destination: "calico.yaml"

    worker.vm.provider "vmware_desktop" do |v|
      v.vmx["memsize"] = 2048
      v.vmx["numvcpus"] = 1
    end

    worker.vm.provision "shell", path: "scripts/common.sh"
    worker.vm.provision "shell", path: "scripts/worker.sh"
  end
  end
end 