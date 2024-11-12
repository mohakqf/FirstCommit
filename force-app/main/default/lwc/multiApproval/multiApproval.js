import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunities from '@salesforce/apex/OpportunityController.getOpportunities';
import startApprovalProcess from '@salesforce/apex/OpportunityController.startApprovalProcess';
import rejectOpportunities from '@salesforce/apex/OpportunityController.rejectOpportunities';
import getUserProfileName from '@salesforce/apex/OpportunityController.getUserProfileName';

export default class OpportunityApproval extends LightningElement  {
    @track opportunities = [];
    @track selectedRowIds = [];
    @track showApproveModal = false;
    @track showRejectModal = false;
    @track rejectReason = '';
    @track approvalComments = '';
    @track profileName = '';
    @track oppCount = false;
    @track OperationalApproval = false;
    @track PricingApproval = false;
    @track AdminApproval = false;
    @track showPricingReason = false;
    @track showAdminReason = false;
    @track showPPICReason = false;
    // Define picklist options for rejection reasons
    @track PPICrejectionReasonOptions = [
        { label: 'Product Not Developed /Not Available', value: 'Product Not Developed /Not Available' },
        { label: 'Product Technical Challenge', value: 'Product Technical Challenge' },
        { label: 'Qty Challenge', value: 'Qty Challenge' },
        { label: 'Lead time Issue', value: 'Lead time Issue' },
        { label: 'Tech Transfer', value: 'Tech Transfer' },
        { label: 'Capacity Constraint', value: 'Capacity Constraint' },
        { label: 'API challenges', value: 'API challenges' }
    ];
    @track PricingrejectionReasonOptions = [
        { label: 'Product Not Developed /Not Available', value: 'Product Not Developed /Not Available' },
        { label: 'Transfer Prices challenge', value: 'Transfer Prices challenge' },
        { label: 'Qty Challenge', value: 'Qty Challenge' },
        { label: 'Packaging Change Part Challenge', value: 'Packaging Change Part Challenge' }
    ];
    @track AdminrejectionReasonOptions = [
        { label: 'Product Not Developed /Not Available', value: 'Product Not Developed /Not Available' },
        { label: 'Product Technical Challenge', value: 'Product Technical Challenge' },
        { label: 'Qty Challenge', value: 'Qty Challenge' },
        { label: 'Lead time Issue', value: 'Lead time Issue' },
        { label: 'Tech Transfer', value: 'Tech Transfer' },
        { label: 'Transfer Prices challenge', value: 'Transfer Prices challenge' },
        { label: 'Capacity Constraint', value: 'Capacity Constraint' },
        { label: 'API challenges', value: 'API challenges' },
        { label: 'Packaging Change Part Challenge', value: 'Packaging Change Part Challenge' }
    ];
    @track selectedRejectionReason = '';
    @track disableApproveBtn = true;
    @track disableBtn = true;
    // Define columns for the datatable
    @track opportunities = [];
    @track error;
    @track selectedRows = []; // Initialize as an empty array
    columns = [
        {
            label: 'Opportunity Name',
            fieldName: 'recordLink',
            type: 'url',
            typeAttributes: { 
                label: { fieldName: 'opportunityName' }, 
                target: '_self' 
            }
        },
        { label: 'Customer Name', fieldName: 'customerName', type: 'text' },
        { label: 'Product Name', fieldName: 'productName', type: 'text' },
        { label: 'Pack Size', fieldName: 'packSize', type: 'text' },
        { label: 'Compositions', fieldName: 'compositions', type: 'text' },
        { label: 'Plant', fieldName: 'plant', type: 'text' },
        { label: 'Firm Quantity', fieldName: 'firmQuantity', type: 'text' },
        {
            label: 'Date', fieldName: 'lastModifiedDate', type: 'date',
            typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit' }
        }
    ];
    connectedCallback() {
        this.fetchOpportunities();
        console.log('fetchOpportunities--', this.fetchOpportunities);

    }
    handleRejectionReasonChange(event) {
        this.selectedRejectionReason = event.detail.value;
        this.disableBtn = !this.selectedRejectionReason;
    }
    // Fetch opportunities based on user's profile
    async fetchOpportunities() {
        try {
            this.profileName = await getUserProfileName();
            const data = await getOpportunities();
            this.opportunities = JSON.parse(data).map(opportunity => {
                opportunity.recordLink = `/lightning/r/Opportunity/${opportunity.id}/view`;
                if (opportunity.LastModifiedBy && opportunity.LastModifiedBy.Name) {
                    opportunity.SName = opportunity.LastModifiedBy.Name;
                    delete opportunity.LastModifiedBy;
                }
                return opportunity;
            });
            if (this.profileName === 'PPIC Approval') {
                this.OperationalApproval = true;
                this.opportunities = this.opportunities.filter(opportunity => opportunity.approval == 'Pending');
            } else if (this.profileName === 'Pricing Approval') {
                this.PricingApproval = true;
                this.opportunities = this.opportunities.filter(opportunity => opportunity.approval == 'Approved');
            } else if (this.profileName === 'System Administrator') {
                this.AdminApproval = true;
                this.opportunities.forEach(opportunity => (opportunity.LastModifiedDate = new Date(opportunity.LastModifiedDate)));
                // columns[{}];
            }
            if (this.opportunities) {
                this.oppCount = true;
            }

        } catch (error) {
            console.error('Error fetching opportunities:', error);
        }
    }

    showApprovalModal() {
        console.log('this.selectedRows 134', this.selectedRows);
        if (this.selectedRowIds.length > 0) {
            this.showApproveModal = true;
            console.log(this.showApproveModal);
        } else {
            console.error('No opportunity selected to approved');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No opportunity selected to approved. Please select an opportunity.',
                    variant: 'error',
                })
            );
        }
    }
    closeApproveModal() {
        this.showApproveModal = false;
    }
    handleApprovalCommentsChange(event) {
        this.approvalComments = event.target.value;
        this.disableApproveBtn = !this.approvalComments;
    }
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRowIds = selectedRows.map(row => row.id);
    }
    handleApprove() {
        if (this.selectedRowIds.length > 0) {
            startApprovalProcess({ opportunityIds: this.selectedRowIds, comments: this.approvalComments })
                .then(result => {
                    console.log('Selected Row IDs:', this.selectedRowIds);
                    console.log('result 188', result);
                    console.log('Opportunity approved successfully:', result);
                    // Show a success toast message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Opportunity approved successfully!',
                            variant: 'success',
                        })
                    );
                    this.showApproveModal = false;
                    this.approvalComments = '';
                    this.fetchOpportunities();
                })
                .catch(error => {
                    console.error('Error approving opportunity:', JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error approving opportunity: ' + error.body.message,
                            variant: 'error',
                        })
                    );
                });
        }
        else {
            console.error('No opportunity selected to approve');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No opportunity selected to Approve. Please select an opportunity.',
                    variant: 'error',
                })
            );
        }
    }
    handleReject() {
        if (this.selectedRowIds.length > 0) {
            this.showRejectModal = true;
            if (this.profileName === 'PPIC Approval') {
                this.showPPICReason = true;
            }
            else if (this.profileName === 'Pricing Approval') {
                this.showPricingReason = true;
            }
            else if (this.profileName === 'System Administrator') {
                this.showAdminReason = true;
            }

        } else {
            console.error('No opportunity selected to reject');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No opportunity selected to reject. Please select an opportunity.',
                    variant: 'error',
                })
            );
        }
    }
    closeRejectModal() {
        this.showRejectModal = false;
        this.rejectReason = '';
    }
    handleRejectInModal() {
        console.log('Rejecting opportunity with reason:', this.selectedRejectionReason);

        rejectOpportunities({ opportunityIds: this.selectedRowIds, rejectionReason: this.selectedRejectionReason })
            .then(result => {
                console.log('Opportunity rejected successfully:', result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunity rejected successfully!',
                        variant: 'success',
                    })
                );

                this.showRejectModal = false;
                this.fetchOpportunities();
                this.selectedRejectionReason = '';
            })
            .catch(error => {
                console.error('Error rejecting opportunity:', JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error rejecting opportunity: ' + error.body.message,
                        variant: 'error',
                    })
                );
            });
    }
}