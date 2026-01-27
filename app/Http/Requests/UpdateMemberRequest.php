<?php
namespace App\Http\Requests;

class UpdateMemberRequest extends StoreMemberRequest
{
    public function rules()
    {
        $rules = parent::rules();
        // Menggunakan $this->route('member') atau ID dari segment URL
        $id = $this->route('member');
        $rules['email'] = 'required|unique:users,email,' . $id;
        
        return $rules;
    }

    public function authorize()
    {
        return true; // Pastikan ini true agar tidak kena error 403
    }
}